import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';

final class MdwAtomicFileService {
  const MdwAtomicFileService();

  static final Map<String, Future<void>> _pendingWrites = <String, Future<void>>{};

  Future<void> write(File target, Uint8List bytes) {
    final previous = _pendingWrites[target.path] ?? Future<void>.value();
    late final Future<void> current;

    current = previous.catchError((_) {}).then((_) async {
      await _writeAtomic(target, bytes);
    }).whenComplete(() {
      if (identical(_pendingWrites[target.path], current)) {
        _pendingWrites.remove(target.path);
      }
    });

    _pendingWrites[target.path] = current;
    return current;
  }

  Future<File> recoverIfNeeded(File target) async {
    final saving = File('${target.path}.saving');
    final backup = File('${target.path}.backup');

    if (await _isValidMdw(target)) {
      await _deleteIfExists(saving);
      await _deleteIfExists(backup);
      return target;
    }

    if (await _isValidMdw(saving)) {
      await _replaceWith(target: target, source: saving, backup: backup);
      return target;
    }

    if (await _isValidMdw(backup)) {
      await _replaceWith(target: target, source: backup, backup: saving);
      return target;
    }

    return target;
  }

  Future<void> _writeAtomic(File target, Uint8List bytes) async {
    _validateArchiveBytes(bytes);

    await target.parent.create(recursive: true);

    final saving = File('${target.path}.saving');
    final backup = File('${target.path}.backup');

    await _deleteIfExists(saving);
    await saving.writeAsBytes(bytes, flush: true);

    if (!await _isValidMdw(saving)) {
      await _deleteIfExists(saving);
      throw const FormatException('The temporary MDW archive failed validation.');
    }

    await _deleteIfExists(backup);

    if (await target.exists()) {
      await target.rename(backup.path);
    }

    try {
      await saving.rename(target.path);
      if (!await _isValidMdw(target)) {
        throw const FormatException('The saved MDW archive failed validation.');
      }
      await _deleteIfExists(backup);
    } on Object {
      if (!await target.exists() && await backup.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    } finally {
      await _deleteIfExists(saving);
    }
  }

  Future<void> _replaceWith({
    required File target,
    required File source,
    required File backup,
  }) async {
    await _deleteIfExists(backup);

    if (await target.exists()) {
      await target.rename(backup.path);
    }

    try {
      await source.rename(target.path);
      if (!await _isValidMdw(target)) {
        throw const FormatException('Recovered MDW archive failed validation.');
      }
      await _deleteIfExists(backup);
    } on Object {
      if (!await target.exists() && await backup.exists()) {
        await backup.rename(target.path);
      }
      rethrow;
    }
  }

  Future<bool> _isValidMdw(File file) async {
    if (!await file.exists()) return false;

    try {
      final bytes = await file.readAsBytes();
      _validateArchiveBytes(bytes);
      return true;
    } on Object {
      return false;
    }
  }

  void _validateArchiveBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes, verify: true);
    final hasManifest = archive.any(
      (entry) => entry.isFile && entry.name == 'manifest.yaml',
    );
    if (!hasManifest) {
      throw const FormatException('Invalid MDW archive: manifest.yaml is missing.');
    }
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
