import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/pages/book_editor_page.dart';
import 'package:markweft_simple_book/features/book_library/data/repositories/mdw_book_project_repository.dart';
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
  final BookProjectRepository _projectRepository =
      MdwBookProjectRepository();
  final RecentProjectsStore _recentProjectsStore = RecentProjectsStore();

  MarkweftProject? _activeProject;
  List<String> _recentProjects = const <String>[];
  bool _isBusy = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentProjects();
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

      final recentProjects = await _recentProjectsStore.add(project.file.path);
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
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Book title',
              hintText: 'My new book',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final normalized = value.trim();
              if (normalized.isNotEmpty) {
                Navigator.of(context).pop(normalized);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final normalized = controller.text.trim();
                if (normalized.isNotEmpty) {
                  Navigator.of(context).pop(normalized);
                }
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markweft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A4036),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F0EA),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,

      ],
      home: _activeProject == null
          ? WelcomePage(
              isBusy: _isBusy,
              errorMessage: _errorMessage,
              recentProjects: _recentProjects,
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
