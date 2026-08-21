import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/core/settings/app_settings.dart';
import 'package:markweft_simple_book/core/settings/app_settings_page.dart';
import 'package:markweft_simple_book/core/settings/app_settings_store.dart';
import 'package:markweft_simple_book/core/ui/dialogs/book_title_dialog.dart';
import 'package:markweft_simple_book/core/ui/theme/markweft_theme.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/pages/book_editor_page.dart';
import 'package:markweft_simple_book/features/book_library/data/repositories/mdw_book_project_repository.dart';
import 'package:markweft_simple_book/features/book_library/data/services/macos_security_scoped_bookmark_service.dart';
import 'package:markweft_simple_book/features/book_library/data/services/mdw_version_converter.dart';
import 'package:markweft_simple_book/features/book_library/data/services/recent_projects_store.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_simple_book/features/book_library/presentation/pages/welcome_page.dart';

final class MarkweftApp extends StatefulWidget {
  const MarkweftApp({super.key});

  @override
  State<MarkweftApp> createState() => _MarkweftAppState();
}

final class _MarkweftAppState extends State<MarkweftApp> {
  static const XTypeGroup _projectType = XTypeGroup(
    label: 'Markweft book',
    extensions: <String>['mdw'],
  );

  final BookProjectRepository _projectRepository = MdwBookProjectRepository();
  final RecentProjectsStore _recentProjectsStore = RecentProjectsStore();
  final MacosSecurityScopedBookmarkService _bookmarkService =
  const MacosSecurityScopedBookmarkService();
  final MdwVersionConverter _versionConverter = const MdwVersionConverter();
  final AppSettingsStore _appSettingsStore = const AppSettingsStore();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  MarkweftProject? _activeProject;
  String? _activeSecurityScopedPath;
  List<String> _recentProjects = const <String>[];
  Map<String, int?> _recentProjectVersions = const <String, int?>{};
  AppSettings _appSettings = const AppSettings();
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentProjects();
    _loadAppSettings();
  }

  Future<void> _loadAppSettings() async {
    final settings = await _appSettingsStore.load();
    await _applyLanguage(settings.languageCode);
    if (!mounted) return;
    setState(() => _appSettings = settings);
  }

  Future<void> _saveAppSettings(AppSettings settings) async {
    await _applyLanguage(settings.languageCode);
    if (!mounted) return;
    setState(() => _appSettings = settings);
    await _appSettingsStore.save(settings);
  }

  Future<void> _applyLanguage(String languageCode) async {
    if (languageCode == 'system') {
      LocaleSettings.useDeviceLocale();
      return;
    }

    await LocaleSettings.setLocaleRaw(languageCode);
  }

  Future<void> _openAppSettings() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final settings = await Navigator.of(context).push<AppSettings>(
      MaterialPageRoute(
        builder: (_) => AppSettingsPage(settings: _appSettings),
      ),
    );
    if (settings == null || !mounted) return;
    await _saveAppSettings(settings);
  }

  Future<void> _loadRecentProjects() async {
    final recentProjects = await _recentProjectsStore.load();
    final versions = <String, int?>{};

    for (final projectPath in recentProjects) {
      versions[projectPath] = await _inspectRecentVersion(projectPath);
    }

    if (!mounted) return;
    setState(() {
      _recentProjects = recentProjects;
      _recentProjectVersions = versions;
    });
  }

  Future<int?> _inspectRecentVersion(String projectPath) async {
    try {
      if (!Platform.isMacOS) {
        return _versionConverter.inspectVersion(projectPath);
      }

      final bookmark = await _recentProjectsStore.bookmarkFor(projectPath);
      if (bookmark == null) return null;
      final resolvedPath = await _bookmarkService.resolveBookmark(bookmark);
      try {
        return await _versionConverter.inspectVersion(resolvedPath);
      } finally {
        await _bookmarkService.stopAccessing(resolvedPath);
      }
    } on Object {
      return null;
    }
  }

  Future<void> _createProject() async {
    final title = await _askForBookTitle(
      title: t.dialogs.bookTitle.create.title,
      actionLabel: t.dialogs.bookTitle.create.action,
    );
    if (title == null) return;
    await _runProjectAction(
          () => _projectRepository.createProject(title: title),
    );
  }

  Future<void> _importMarkdown() async {
    final title = await _askForBookTitle(
      title: t.dialogs.bookTitle.import.title,
      actionLabel: t.dialogs.bookTitle.import.action,
    );
    if (title == null) return;
    await _runProjectAction(
          () => _projectRepository.importMarkdown(title: title),
    );
  }

  Future<int?> _chooseTargetVersion(BuildContext context) {
    final tr = Translations.of(context);
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.welcome.conversion.dialog.title),
        content: Text(tr.welcome.conversion.dialog.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr.app.actions.cancel),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(1),
            child: Text(tr.welcome.conversion.dialog.toV1),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              MdwVersionConverter.currentVersion,
            ),
            child: Text(tr.welcome.conversion.dialog.toV3),
          ),
        ],
      ),
    );
  }

  Future<_ConversionChoice?> _chooseConversionMode(BuildContext context) {
    var mode = MdwConversionMode.saveCopy;
    var openAfter = true;
    final tr = Translations.of(context);

    return showDialog<_ConversionChoice>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tr.welcome.conversion.dialog.storageTitle),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<MdwConversionMode>(
                  value: MdwConversionMode.replaceSource,
                  groupValue: mode,
                  title: Text(tr.welcome.conversion.dialog.sameFile),
                  subtitle: Text(
                    tr.welcome.conversion.dialog.sameFileDescription,
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => mode = value);
                  },
                ),
                RadioListTile<MdwConversionMode>(
                  value: MdwConversionMode.saveCopy,
                  groupValue: mode,
                  title: Text(tr.welcome.conversion.dialog.saveCopy),
                  subtitle: Text(
                    tr.welcome.conversion.dialog.saveCopyDescription,
                  ),
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => mode = value);
                  },
                ),
                const Divider(),
                CheckboxListTile(
                  value: openAfter,
                  title: Text(tr.welcome.conversion.dialog.openAfter),
                  subtitle: Text(
                    tr.welcome.conversion.dialog.openAfterDescription,
                  ),
                  onChanged: (value) {
                    setDialogState(() => openAfter = value ?? true);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(tr.app.actions.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(
                _ConversionChoice(mode: mode, openAfter: openAfter),
              ),
              child: Text(tr.welcome.quickActions.convertVersion.title),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convertBookVersion({
    String? sourcePath,
    int? targetVersion,
  }) async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final target = targetVersion ?? await _chooseTargetVersion(context);
    if (target == null) return;
    final choice = await _chooseConversionMode(context);
    if (choice == null) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    String? scopedPath;
    try {
      MdwConversionResult? result;
      if (sourcePath == null) {
        result = await _versionConverter.pickAndConvert(
          targetVersion: target,
          mode: choice.mode,
        );
      } else {
        var accessiblePath = sourcePath;
        if (Platform.isMacOS) {
          final bookmark = await _recentProjectsStore.bookmarkFor(sourcePath);
          if (bookmark != null) {
            scopedPath = await _bookmarkService.resolveBookmark(bookmark);
            accessiblePath = scopedPath;
          }
        }
        result = await _versionConverter.convertPath(
          sourcePath: accessiblePath,
          targetVersion: target,
          mode: choice.mode,
        );
      }

      if (result == null || !mounted) return;

      String? bookmark;
      try {
        bookmark = await _bookmarkService.createBookmark(result.outputPath);
      } on Object {
        // Conversion succeeded; bookmark can be refreshed on the next manual open.
      }
      await _recentProjectsStore.add(result.outputPath, bookmark: bookmark);
      await _loadRecentProjects();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.welcome.conversion.success(path: result.outputPath),
          ),
        ),
      );

      if (choice.openAfter) {
        await _runProjectAction(
              () => _projectRepository.openProject(result!.outputPath),
        );
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = t.welcome.conversion.failure(error: '$error');
      });
    } finally {
      if (scopedPath != null) {
        await _bookmarkService.stopAccessing(scopedPath);
      }
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickProject() async {
    final selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (selected == null) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final version = await _versionConverter.inspectVersion(selected.path);
      if (!mounted) return;

      if (version != MdwVersionConverter.currentVersion) {
        setState(() => _isBusy = false);
        await _convertBookVersion(
          sourcePath: selected.path,
          targetVersion: MdwVersionConverter.currentVersion,
        );
        return;
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _errorMessage = t.welcome.errors.openBook(error: '$error');
      });
      return;
    }

    if (mounted) setState(() => _isBusy = false);
    await _runProjectAction(
          () => _projectRepository.openProject(selected.path),
    );
  }

  Future<void> _openRecentProject(String projectPath) async {
    final version = _recentProjectVersions[projectPath];
    if (version != null && version != MdwVersionConverter.currentVersion) {
      await _convertBookVersion(
        sourcePath: projectPath,
        targetVersion: MdwVersionConverter.currentVersion,
      );
      return;
    }

    if (Platform.isMacOS) {
      final bookmark = await _recentProjectsStore.bookmarkFor(projectPath);
      if (bookmark == null) {
        setState(() => _errorMessage = t.welcome.errors.legacyBookmark);
        return;
      }

      try {
        final resolvedPath = await _bookmarkService.resolveBookmark(bookmark);
        _activeSecurityScopedPath = resolvedPath;
        await _runProjectAction(
              () => _projectRepository.openProject(resolvedPath),
        );
        return;
      } on Object catch (error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = t.welcome.errors.bookmarkRestore(error: '$error');
        });
        return;
      }
    }

    await _runProjectAction(() => _projectRepository.openProject(projectPath));
  }

  Future<void> _runProjectAction(
      Future<MarkweftProject?> Function() action,
      ) async {
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final project = await action();
      if (project == null || !mounted) return;

      String? bookmark;
      try {
        bookmark = await _bookmarkService.createBookmark(project.file.path);
      } on Object {
        // The project is already open. Bookmark failure only affects relaunch.
      }

      final recentProjects = await _recentProjectsStore.add(
        project.file.path,
        bookmark: bookmark,
      );
      if (!mounted) return;

      setState(() {
        _activeProject = project;
        _recentProjects = recentProjects;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = t.welcome.errors.openBook(error: '$error');
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _closeProject() async {
    final project = _activeProject;
    if (project == null) return;

    await _projectRepository.closeProject(project);

    final securityScopedPath = _activeSecurityScopedPath;
    _activeSecurityScopedPath = null;
    if (securityScopedPath != null) {
      await _bookmarkService.stopAccessing(securityScopedPath);
    }

    if (!mounted) return;
    setState(() {
      _activeProject = null;
      _errorMessage = null;
    });
    await _loadRecentProjects();
  }

  Future<void> _removeRecentProject(String projectPath) async {
    final updated = await _recentProjectsStore.remove(projectPath);
    if (!mounted) return;
    setState(() {
      _recentProjects = updated;
      _recentProjectVersions = Map<String, int?>.of(_recentProjectVersions)
        ..remove(projectPath);
    });
  }

  Future<String?> _askForBookTitle({
    required String title,
    required String actionLabel,
  }) async {
    final dialogContext = _navigatorKey.currentContext;
    if (dialogContext == null) return null;

    return showDialog<String>(
      context: dialogContext,
      builder: (context) => BookTitleDialog(
        title: title,
        actionLabel: actionLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: t.app.identity.name,
      debugShowCheckedModeBanner: false,
      theme: MarkweftTheme.light(),
      darkTheme: MarkweftTheme.dark(),
      themeMode: _appSettings.themeMode,
      locale: TranslationProvider.of(context).flutterLocale,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppLocaleUtils.supportedLocales,
      home: _activeProject == null
          ? WelcomePage(
        isBusy: _isBusy,
        errorMessage: _errorMessage,
        recentProjects: _recentProjects,
        recentProjectVersions: _recentProjectVersions,
        currentMdwVersion: MdwVersionConverter.currentVersion,
        showRecentBookPaths: _appSettings.showRecentBookPaths,
        onOpenAppSettings: _openAppSettings,
        onCreateBook: _createProject,
        onOpenBook: _pickProject,
        onImportMarkdown: _importMarkdown,
        onConvertBookVersion: () => _convertBookVersion(),
        onConvertRecent: (projectPath) => _convertBookVersion(
          sourcePath: projectPath,
          targetVersion: MdwVersionConverter.currentVersion,
        ),
        onOpenRecent: _openRecentProject,
        onRemoveRecent: _removeRecentProject,
      )
          : BookEditorPage(
        key: ValueKey(_activeProject!.file.path),
        project: _activeProject!,
        projectRepository: _projectRepository,
        onOpenAppSettings: _openAppSettings,
        onClose: _closeProject,
      ),
    );
  }
}

final class _ConversionChoice {
  const _ConversionChoice({
    required this.mode,
    required this.openAfter,
  });

  final MdwConversionMode mode;
  final bool openAfter;
}
