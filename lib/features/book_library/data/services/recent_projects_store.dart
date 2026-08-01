import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

final class RecentProjectsStore {
  static const String _storageKey = 'markweft_recent_projects';
  static const int _maximumItems = 10;

  Future<List<String>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final paths = preferences.getStringList(_storageKey) ?? const <String>[];

    final existing = paths.where((path) => File(path).existsSync()).toList();
    if (existing.length != paths.length) {
      await preferences.setStringList(_storageKey, existing);
    }

    return existing;
  }

  Future<List<String>> add(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await load();
    final updated = <String>[
      projectPath,
      ...current.where((path) => path != projectPath),
    ].take(_maximumItems).toList(growable: false);

    await preferences.setStringList(_storageKey, updated);
    return updated;
  }

  Future<List<String>> remove(String projectPath) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await load();
    final updated = current
        .where((path) => path != projectPath)
        .toList(growable: false);

    await preferences.setStringList(_storageKey, updated);
    return updated;
  }
}
