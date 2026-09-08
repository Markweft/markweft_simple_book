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
    // A file chosen through the macOS sandbox grants read/write access to the
    // selected file, not to arbitrary sibling paths. The macOS write path
    // therefore never creates `.saving` or `.backup` files beside the book.
    if (Platform.isMacOS) {
      return target;
    }

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

    // macOS App Sandbox access obtained from NSSavePanel/NSOpenPanel is scoped
    // to the exact user-selected file. Creating `${target.path}.saving` or
    // `${target.path}.backup` beside a book on Desktop/Documents therefore
    // fails with EPERM even though writing the selected .mdw itself is allowed.
    //
    // Keep the queued/validated write semantics, but write the selected file
    // directly on macOS. Other desktop platforms retain the sibling-file
    // atomic replace/recovery strategy below.
    if (Platform.isMacOS) {
      await _writeSelectedMacOsFile(target, bytes);
      return;
    }

    if (!await target.parent.exists()) {
      await target.parent.create(recursive: true);
    }

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

  Future<void> _writeSelectedMacOsFile(File target, Uint8List bytes) async {
    // Do not attempt to create the parent directory here. For a security-scoped
    // file outside the app container, the app owns permission to the selected
    // file but not necessarily to mutate its parent directory.
    await target.writeAsBytes(bytes, flush: true);

    if (!await _isValidMdw(target)) {
      throw const FormatException('The saved MDW archive failed validation.');
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
