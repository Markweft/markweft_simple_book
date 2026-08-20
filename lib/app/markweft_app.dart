import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
    if (!mounted) return;
    setState(() => _appSettings = settings);
  }

  Future<void> _saveAppSettings(AppSettings settings) async {
    setState(() => _appSettings = settings);
    await _appSettingsStore.save(settings);
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
    if (!mounted) return;
    setState(() => _recentProjects = recentProjects);
  }

  Future<void> _createProject() async {
    final title = await _askForBookTitle(
      title: 'Create new book',
      actionLabel: 'Create',
    );
    if (title == null) return;
    await _runProjectAction(
      () => _projectRepository.createProject(title: title),
    );
  }

  Future<void> _importMarkdown() async {
    final title = await _askForBookTitle(
      title: 'Import Markdown book',
      actionLabel: 'Import',
    );
    if (title == null) return;
    await _runProjectAction(
      () => _projectRepository.importMarkdown(title: title),
    );
  }

  Future<void> _convertBookVersion() async {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    final targetVersion = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Convert book version'),
        content: const Text(
          'A new .mdw copy will be created. The source book is never modified. '
          'Version 1 is the original single-Markdown format. Version 3 is the '
          'current chapter-based format.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(1),
            child: const Text('Convert to v1'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(3),
            child: const Text('Convert to v3'),
          ),
        ],
      ),
    );
    if (targetVersion == null) return;

    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });

    try {
      final output = await _versionConverter.pickAndConvert(
        targetVersion: targetVersion,
      );
      if (output == null || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Converted book saved to $output')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to convert the book: $error';
      });
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickProject() async {
    await _runProjectAction(_projectRepository.pickAndOpenProject);
  }

  Future<void> _openRecentProject(String path) async {
    if (Platform.isMacOS) {
      final bookmark = await _recentProjectsStore.bookmarkFor(path);
      if (bookmark == null) {
        setState(() {
          _errorMessage =
              'This recent book was saved by an older Markweft version. '
              'Use Open book once and select it again so macOS can save persistent access.';
        });
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
          _errorMessage =
              'Unable to restore macOS permission for this book. '
              'Open it once with Open book to refresh access. ($error)';
        });
        return;
      }
    }

    await _runProjectAction(() => _projectRepository.openProject(path));
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
        _errorMessage = 'Unable to open the book: $error';
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

  Future<void> _removeRecentProject(String path) async {
    final updated = await _recentProjectsStore.remove(path);
    if (!mounted) return;
    setState(() => _recentProjects = updated);
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
      title: 'Markweft',
      debugShowCheckedModeBanner: false,
      theme: MarkweftTheme.light(),
      darkTheme: MarkweftTheme.dark(),
      themeMode: _appSettings.themeMode,
      locale: _appSettings.locale,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      home: _activeProject == null
          ? WelcomePage(
              isBusy: _isBusy,
              errorMessage: _errorMessage,
              recentProjects: _recentProjects,
              showRecentBookPaths: _appSettings.showRecentBookPaths,
              onOpenAppSettings: _openAppSettings,
              onCreateBook: _createProject,
              onOpenBook: _pickProject,
              onImportMarkdown: _importMarkdown,
              onConvertBookVersion: _convertBookVersion,
              onOpenRecent: _openRecentProject,
              onRemoveRecent: _removeRecentProject,
            )
          : BookEditorPage(
              key: ValueKey(_activeProject!.file.path),
              project: _activeProject!,
              projectRepository: _projectRepository,
              onClose: _closeProject,
            ),
    );
  }
}
