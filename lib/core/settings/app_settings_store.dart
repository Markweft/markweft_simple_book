import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppSettingsStore {
  const AppSettingsStore();

  static const String _themeKey = 'app_settings.theme_mode';
  static const String _languageKey = 'app_settings.language_code';
  static const String _showRecentPathsKey = 'app_settings.show_recent_paths';
  static const String _confirmDestructiveKey =
      'app_settings.confirm_destructive_actions';

  Future<AppSettings> load() async {
    final preferences = await SharedPreferences.getInstance();

    return AppSettings(
      themeMode: _decodeTheme(preferences.getString(_themeKey)),
      languageCode: preferences.getString(_languageKey) ?? 'system',
      showRecentBookPaths: preferences.getBool(_showRecentPathsKey) ?? true,
      confirmDestructiveActions:
          preferences.getBool(_confirmDestructiveKey) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_themeKey, settings.themeMode.name),
      preferences.setString(_languageKey, settings.languageCode),
      preferences.setBool(_showRecentPathsKey, settings.showRecentBookPaths),
      preferences.setBool(
        _confirmDestructiveKey,
        settings.confirmDestructiveActions,
      ),
    ]);
  }

  ThemeMode _decodeTheme(String? value) {
    return ThemeMode.values.where((mode) => mode.name == value).firstOrNull ??
        ThemeMode.system;
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
