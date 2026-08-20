import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/settings/app_settings.dart';
import 'package:markweft_simple_book/i18n/strings.g.dart';

final class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({
    required this.settings,
    super.key,
  });

  final AppSettings settings;

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

final class _AppSettingsPageState extends State<AppSettingsPage> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tr = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.settings.title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_settings),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(tr.app.done),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 44),
            children: [
              _SettingsSection(
                title: tr.settings.appearance,
                subtitle: tr.settings.appearanceDescription,
                child: _SettingRow(
                  icon: Icons.palette_outlined,
                  title: tr.settings.themeMode,
                  subtitle: tr.settings.themeModeDescription,
                  trailing: DropdownButton<ThemeMode>(
                    value: _settings.themeMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(tr.app.system),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(tr.app.light),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(tr.app.dark),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _settings = _settings.copyWith(themeMode: value);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: tr.settings.languageRegion,
                subtitle: tr.settings.languageRegionDescription,
                child: _SettingRow(
                  icon: Icons.language_rounded,
                  title: tr.settings.appLanguage,
                  subtitle: tr.settings.appLanguageDescription,
                  trailing: DropdownButton<String>(
                    value: _settings.languageCode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: 'system',
                        child: Text(tr.app.system),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(tr.app.english),
                      ),
                      DropdownMenuItem(
                        value: 'ar',
                        child: Text(tr.app.arabic),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _settings = _settings.copyWith(languageCode: value);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: tr.settings.privacyWorkspace,
                subtitle: tr.settings.privacyWorkspaceDescription,
                child: _SettingRow(
                  icon: Icons.folder_outlined,
                  title: tr.settings.showRecentPaths,
                  subtitle: tr.settings.showRecentPathsDescription,
                  trailing: Switch(
                    value: _settings.showRecentBookPaths,
                    onChanged: (value) {
                      setState(() {
                        _settings =
                            _settings.copyWith(showRecentBookPaths: value);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: tr.settings.safety,
                subtitle: tr.settings.safetyDescription,
                child: _SettingRow(
                  icon: Icons.shield_outlined,
                  title: tr.settings.confirmDestructive,
                  subtitle: tr.settings.confirmDestructiveDescription,
                  trailing: Switch(
                    value: _settings.confirmDestructiveActions,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          confirmDestructiveActions: value,
                        );
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tr.settings.bookSettingsNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          child,
        ],
      ),
    );
  }
}

final class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }
}
