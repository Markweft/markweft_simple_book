import 'dart:convert';

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
    int? version,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await _loadEntries();
    final previous = current.where((entry) => entry.path == projectPath).firstOrNull;
    final updated = <_RecentProjectEntry>[
      _RecentProjectEntry(
        path: projectPath,
        bookmark: bookmark ?? previous?.bookmark,
        version: version ?? previous?.version,
      ),
      ...current.where((entry) => entry.path != projectPath),
    ].take(_maximumItems).toList(growable: false);

    await _saveEntries(preferences, updated);
    return updated.map((entry) => entry.path).toList(growable: false);
  }

  Future<void> cacheVersion(String projectPath, int version) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await _loadEntries();
    final updated = [
      for (final entry in current)
        if (entry.path == projectPath)
          entry.copyWith(version: version)
        else
          entry,
    ];
    await _saveEntries(preferences, updated);
  }

  Future<int?> versionFor(String projectPath) async {
    final entries = await _loadEntries();
    for (final entry in entries) {
      if (entry.path == projectPath) return entry.version;
    }
    return null;
  }

  Future<String?> bookmarkFor(String projectPath) async {
    final entries = await _loadEntries();
    for (final entry in entries) {
      if (entry.path == projectPath) return entry.bookmark;
    }
    return null;
  }

  Future<List<String>> remove(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await _loadEntries();
    final updated = current
        .where((entry) => entry.path != projectPath)
        .toList(growable: false);

    await _saveEntries(preferences, updated);
    return updated.map((entry) => entry.path).toList(growable: false);
  }

  Future<List<_RecentProjectEntry>> _loadEntries() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? const <String>[];
    final entries = <_RecentProjectEntry>[];

    for (final value in stored) {
      final entry = _decodeEntry(value);
      if (entry != null) entries.add(entry);
    }

    final normalized = entries.take(_maximumItems).toList(growable: false);
    if (normalized.length != stored.length ||
        !stored.every((value) => value.trimLeft().startsWith('{'))) {
      await _saveEntries(preferences, normalized);
    }

    return normalized;
  }

  Future<void> _saveEntries(
    SharedPreferences preferences,
    List<_RecentProjectEntry> entries,
  ) {
    return preferences.setStringList(
      _storageKey,
      entries.map((entry) => jsonEncode(entry.toJson())).toList(growable: false),
    );
  }

  _RecentProjectEntry? _decodeEntry(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final projectPath = decoded['path']?.toString();
        if (projectPath == null || projectPath.isEmpty) return null;
        final bookmark = decoded['bookmark']?.toString();
        final rawVersion = decoded['version'];
        final version = rawVersion is int ? rawVersion : int.tryParse('$rawVersion');
        return _RecentProjectEntry(
          path: projectPath,
          bookmark: bookmark == null || bookmark.isEmpty ? null : bookmark,
          version: version,
        );
      }
    } on FormatException {
      // Legacy versions stored raw file-system paths.
    }

    final projectPath = value.trim();
    return projectPath.isEmpty ? null : _RecentProjectEntry(path: projectPath);
  }
}

final class _RecentProjectEntry {
  const _RecentProjectEntry({
    required this.path,
    this.bookmark,
    this.version,
  });

  final String path;
  final String? bookmark;
  final int? version;

  _RecentProjectEntry copyWith({int? version}) {
    return _RecentProjectEntry(
      path: path,
      bookmark: bookmark,
      version: version ?? this.version,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'path': path,
        if (bookmark != null) 'bookmark': bookmark,
        if (version != null) 'version': version,
      };
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
