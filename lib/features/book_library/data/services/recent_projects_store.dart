import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

final class RecentProjectsStore {
  static const String _storageKey = 'markweft_recent_projects';
  static const int _maximumItems = 10;

  Future<List<String>> load() async {
    final entries = await _loadEntries();
    return entries.map((entry) => entry.path).toList(growable: false);
  }

  Future<List<String>> add(
    String projectPath, {
    String? bookmark,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await _loadEntries();
    final previous = current.where((entry) => entry.path == projectPath).firstOrNull;
    final updated = <_RecentProjectEntry>[
      _RecentProjectEntry(
        path: projectPath,
        bookmark: bookmark ?? previous?.bookmark,
      ),
      ...current.where((entry) => entry.path != projectPath),
    ].take(_maximumItems).toList(growable: false);

    await preferences.setStringList(
      _storageKey,
      updated.map((entry) => jsonEncode(entry.toJson())).toList(growable: false),
    );

    return updated.map((entry) => entry.path).toList(growable: false);
  }

  Future<String?> bookmarkFor(String projectPath) async {
    final entries = await _loadEntries();
    for (final entry in entries) {
      if (entry.path == projectPath) {
        return entry.bookmark;
      }
    }
    return null;
  }

  Future<List<String>> remove(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await _loadEntries();
    final updated = current
        .where((entry) => entry.path != projectPath)
        .toList(growable: false);

    await preferences.setStringList(
      _storageKey,
      updated.map((entry) => jsonEncode(entry.toJson())).toList(growable: false),
    );

    return updated.map((entry) => entry.path).toList(growable: false);
  }

  Future<List<_RecentProjectEntry>> _loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? const <String>[];
    final entries = <_RecentProjectEntry>[];

    for (final value in stored) {
      final entry = _decodeEntry(value);
      if (entry == null) {
        continue;
      }

      if (entry.bookmark != null || File(entry.path).existsSync()) {
        entries.add(entry);
      }
    }

    final normalized = entries.take(_maximumItems).toList(growable: false);
    if (normalized.length != stored.length ||
        !stored.every((value) => value.trimLeft().startsWith('{'))) {
      await preferences.setStringList(
        _storageKey,
        normalized
            .map((entry) => jsonEncode(entry.toJson()))
            .toList(growable: false),
      );
    }

    return normalized;
  }

  _RecentProjectEntry? _decodeEntry(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final path = decoded['path']?.toString();
        if (path == null || path.isEmpty) {
          return null;
        }
        final bookmark = decoded['bookmark']?.toString();
        return _RecentProjectEntry(
          path: path,
          bookmark: bookmark == null || bookmark.isEmpty ? null : bookmark,
        );
      }
    } on FormatException {
      // Legacy versions stored raw file-system paths.
    }

    final path = value.trim();
    return path.isEmpty ? null : _RecentProjectEntry(path: path);
  }
}

final class _RecentProjectEntry {
  const _RecentProjectEntry({
    required this.path,
    this.bookmark,
  });

  final String path;
  final String? bookmark;

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        if (bookmark != null) 'bookmark': bookmark,
      };
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
