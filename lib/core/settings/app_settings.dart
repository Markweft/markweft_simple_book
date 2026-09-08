import 'package:flutter/material.dart';

final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'system',
    this.showRecentBookPaths = true,
    this.confirmDestructiveActions = true,
  });

  final ThemeMode themeMode;
  final String languageCode;
  final bool showRecentBookPaths;
  final bool confirmDestructiveActions;

  Locale? get locale => languageCode == 'system' ? null : Locale(languageCode);

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? showRecentBookPaths,
    bool? confirmDestructiveActions,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      showRecentBookPaths: showRecentBookPaths ?? this.showRecentBookPaths,
      confirmDestructiveActions:
          confirmDestructiveActions ?? this.confirmDestructiveActions,
    );
  }
}
