import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:markweft_simple_book/core/ui/dialogs/book_title_dialog.dart';
import 'package:markweft_simple_book/core/ui/theme/markweft_theme.dart';
import 'package:markweft_simple_book/core/ui/theme/theme_mode_store.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/pages/book_editor_page.dart';
import 'package:markweft_simple_book/features/book_library/data/repositories/mdw_book_project_repository.dart';
import 'package:markweft_simple_book/features/book_library/data/services/macos_security_scoped_bookmark_service.dart';
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
  final ThemeModeStore _themeModeStore = const ThemeModeStore();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  MarkweftProject? _activeProject;
  String? _activeSecurityScopedPath;
  List<String> _recentProjects = const <String>[];
  ThemeMode _themeMode = ThemeMode.system;
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentProjects();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final mode = await _themeModeStore.load();
    if (!mounted) {
      return;
    }

    setState(() => _themeMode = mode);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    setState(() => _themeMode = mode);
    await _themeModeStore.save(mode);
  }

  Future<void> _loadRecentProjects() async {
    final recentProjects = await _recentProjectsStore.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _recentProjects = recentProjects;
    });
  }

  Future<void> _createProject() async {
    final title = await _askForBookTitle(
      title: 'Create new book',
      actionLabel: 'Create',
    );
    if (title == null) {
      return;
    }

    await _runProjectAction(
      () => _projectRepository.createProject(title: title),
    );
  }

  Future<void> _importMarkdown() async {
    final title = await _askForBookTitle(
      title: 'Import Markdown book',
      actionLabel: 'Import',
    );
    if (title == null) {
      return;
    }

    await _runProjectAction(
      () => _projectRepository.importMarkdown(title: title),
    );
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
        if (!mounted) {
          return;
        }
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
      if (project == null || !mounted) {
        return;
      }

      String? bookmark;
      try {
        bookmark = await _bookmarkService.createBookmark(project.file.path);
      } on Object {
        // The project itself is already open. Failure to persist the bookmark
        // must not prevent editing; it only affects a future macOS relaunch.
      }

      final recentProjects = await _recentProjectsStore.add(
        project.file.path,
        bookmark: bookmark,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _activeProject = project;
        _recentProjects = recentProjects;
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to open the book: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _closeProject() async {
    final project = _activeProject;
    if (project == null) {
      return;
    }

    await _projectRepository.closeProject(project);

    final securityScopedPath = _activeSecurityScopedPath;
    _activeSecurityScopedPath = null;
    if (securityScopedPath != null) {
      await _bookmarkService.stopAccessing(securityScopedPath);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _activeProject = null;
      _errorMessage = null;
    });
    await _loadRecentProjects();
  }

  Future<void> _removeRecentProject(String path) async {
    final updated = await _recentProjectsStore.remove(path);
    if (!mounted) {
      return;
    }

    setState(() {
      _recentProjects = updated;
    });
  }

  Future<String?> _askForBookTitle({
    required String title,
    required String actionLabel,
  }) async {
    final dialogContext = _navigatorKey.currentContext;

    if (dialogContext == null) {
      return null;
    }

    return showDialog<String>(
      context: dialogContext,
      builder: (context) {
        return BookTitleDialog(
          title: title,
          actionLabel: actionLabel,
        );
      },
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
      themeMode: _themeMode,
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
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
              onCreateBook: _createProject,
              onOpenBook: _pickProject,
              onImportMarkdown: _importMarkdown,
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
