import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class ThemeModeStore {
  const ThemeModeStore();

  static const String _key = 'markweft_theme_mode';

  Future<ThemeMode> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_key);

    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> save(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, mode.name);
  }
}
