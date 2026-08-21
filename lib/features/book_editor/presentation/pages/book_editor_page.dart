import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_compilation_service.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_export_service.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_output_format.dart';
import 'package:markweft_simple_book/features/book_editor/application/template_registry.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/book_preview_panel.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/book_settings_dialog.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/markdown_command_toolbar.dart';
import 'package:markweft_simple_book/features/book_history/data/services/book_history_service.dart';
import 'package:markweft_simple_book/features/book_history/presentation/pages/book_history_page.dart';
import 'package:markweft_simple_book/features/book_library/data/extensions/chapter_management_repository_extensions.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;

enum SaveStatus { loading, saved, saving, failed }

final class BookEditorPage extends StatefulWidget {
  const BookEditorPage({
    required this.project,
    required this.projectRepository,
    required this.onOpenAppSettings,
    required this.onClose,
    super.key,
  });

  final MarkweftProject project;
  final BookProjectRepository projectRepository;
  final VoidCallback onOpenAppSettings;
  final Future<void> Function() onClose;

  @override
  State<BookEditorPage> createState() => _BookEditorPageState();
}

final class _BookEditorPageState extends State<BookEditorPage> {
  static const int _livePreviewCharacterLimit = 350000;
  static const BookExportService _exportService = BookExportService();
  static const BookCompilationService _compilationService =
      BookCompilationService();
  static const BookHistoryService _historyService = BookHistoryService();

  late final TextEditingController _controller;
  Timer? _saveDebounce;
  Timer? _previewDebounce;
  Timer? _projectFlushDebounce;

  List<BookChapterFile> _chapters = const <BookChapterFile>[];
  BookChapterFile? _activeChapter;
  BookSettings _bookSettings = const BookSettings();
  BookWorkspaceMode _workspaceMode = BookWorkspaceMode.edit;
  String _draftMarkdown = '';
  String _previewMarkdown = '';
  String? _pendingMarkdown;
  String? _errorMessage;
  bool _saveInProgress = false;
  bool _exportInProgress = false;
  bool _settingsInProgress = false;
  bool _largeChapterPreviewPaused = false;
  bool _sidebarVisible = true;
  bool _previewVisible = true;
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;

  BookTemplate get _template => TemplateRegistry.resolve(_bookSettings.templateId);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    unawaited(_loadBook());
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _previewDebounce?.cancel();
    _projectFlushDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      final settings = await widget.projectRepository.loadBookSettings(widget.project);
      var chapters = await widget.projectRepository.loadChapters(widget.project);
      if (chapters.isEmpty) {
        await widget.projectRepository.createChapter(
          widget.project,
          title: Translations.of(context).editor.chapterManager.defaultFirst,
        );
        chapters = await widget.projectRepository.loadChapters(widget.project);
      }

      final first = chapters.first;
      final markdown = await widget.projectRepository.loadChapterMarkdown(
        widget.project,
        first,
      );
      if (!mounted) return;

      _controller.value = TextEditingValue(
        text: markdown,
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {
        _bookSettings = settings;
        _chapters = chapters;
        _activeChapter = first;
        _setLoadedMarkdown(markdown);
        _saveStatus = SaveStatus.saved;
        _errorMessage = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saveStatus = SaveStatus.failed;
        _errorMessage = Translations.of(context)
            .editor
            .save
            .errors
            .loadBook(error: '$error');
      });
    }
  }

  void _setLoadedMarkdown(String markdown) {
    _draftMarkdown = markdown;
    _largeChapterPreviewPaused = markdown.length > _livePreviewCharacterLimit;
    _previewMarkdown = _largeChapterPreviewPaused ? '' : markdown;
  }

  void _onMarkdownChanged(String value) {
    _draftMarkdown = value;
    setState(() {
      _saveStatus = SaveStatus.saving;
      _errorMessage = null;
      _largeChapterPreviewPaused = value.length > _livePreviewCharacterLimit;
    });

    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_queueSave(value)),
    );

    _previewDebounce?.cancel();
    if (!_largeChapterPreviewPaused) {
      _previewDebounce = Timer(
        const Duration(milliseconds: 300),
        () {
          if (mounted) setState(() => _previewMarkdown = _draftMarkdown);
        },
      );
    }
  }

  Future<void> _queueSave(String markdown) {
    _pendingMarkdown = markdown;
    if (_saveInProgress) {
      return _saveCompleter?.future ?? Future<void>.value();
    }
    _saveInProgress = true;
    _saveCompleter = Completer<void>();
    unawaited(_drainSaveQueue());
    return _saveCompleter!.future;
  }

  Future<void> _drainSaveQueue() async {
    try {
      while (_pendingMarkdown != null) {
        final chapter = _activeChapter;
        if (chapter == null) break;
        final value = _pendingMarkdown!;
        _pendingMarkdown = null;
        await widget.projectRepository.saveChapterMarkdown(
          widget.project,
          chapter,
          value,
        );
      }

      await _historyService.createSnapshotIfChanged(
        project: widget.project,
        repository: widget.projectRepository,
        reason: 'recovery',
        message: Translations.of(context).editor.save.automaticRecovery,
        enforceRecoveryInterval: true,
      );
      unawaited(_historyService.pruneRecoveryVersions(widget.project));
      _scheduleProjectFlush();

      if (mounted) {
        setState(() {
          _saveStatus = SaveStatus.saved;
          _errorMessage = null;
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saveStatus = SaveStatus.failed;
          _errorMessage = Translations.of(context)
              .editor
              .save
              .errors
              .saveChapter(error: '$error');
        });
      }
    } finally {
      _saveInProgress = false;
      _saveCompleter?.complete();
      _saveCompleter = null;
    }
  }

  void _scheduleProjectFlush() {
    _projectFlushDebounce?.cancel();
    _projectFlushDebounce = Timer(
      const Duration(seconds: 5),
      () => unawaited(_flushProject()),
    );
  }

  Future<void> _flushProject() async {
    try {
      await widget.projectRepository.flushProject(widget.project);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saveStatus = SaveStatus.failed;
        _errorMessage = Translations.of(context)
            .editor
            .save
            .errors
            .flushProject(error: '$error');
      });
    }
  }

  Future<void> _saveNow({bool flushProject = true}) async {
    _saveDebounce?.cancel();
    if (mounted) setState(() => _saveStatus = SaveStatus.saving);
    await _queueSave(_controller.text);
    if (flushProject) {
      _projectFlushDebounce?.cancel();
      await _flushProject();
    }
  }

  Future<void> _selectChapter(BookChapterFile chapter) async {
    if (chapter.id == _activeChapter?.id || _saveStatus == SaveStatus.loading) {
      return;
    }
    await _saveNow(flushProject: false);
    if (!mounted || _saveStatus == SaveStatus.failed) return;

    setState(() => _saveStatus = SaveStatus.loading);
    try {
      final markdown = await widget.projectRepository.loadChapterMarkdown(
        widget.project,
        chapter,
      );
      if (!mounted) return;
      _controller.value = TextEditingValue(
        text: markdown,
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {
        _activeChapter = chapter;
        _setLoadedMarkdown(markdown);
        _saveStatus = SaveStatus.saved;
        _errorMessage = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saveStatus = SaveStatus.failed;
        _errorMessage = Translations.of(context)
            .editor
            .save
            .errors
            .openChapter(error: '$error');
      });
    }
  }

  Future<void> _addChapter({String? parentId}) async {
    final tr = Translations.of(context);
    final title = await _askForChapterTitle(
      title: parentId == null
          ? tr.editor.chapterManager.add
          : tr.editor.chapterManager.addChild,
    );
    if (title == null || !mounted) return;

    await _saveNow(flushProject: false);
    final chapter = await widget.projectRepository.createChapter(
      widget.project,
      title: title,
      parentId: parentId,
    );
    final chapters = await widget.projectRepository.loadChapters(widget.project);
    if (!mounted) return;
    setState(() => _chapters = chapters);
    await _selectChapter(chapter);
  }

  Future<void> _renameChapter(BookChapterFile chapter) async {
    final title = await _askForChapterTitle(
      title: Translations.of(context).editor.chapterManager.renameTitle,
      initialValue: chapter.title,
    );
    if (title == null || !mounted) return;

    await _saveNow(flushProject: false);
    final updated = await widget.projectRepository.renameChapter(
      widget.project,
      chapter,
      title: title,
    );
    final chapters = await widget.projectRepository.loadChapters(widget.project);
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      if (_activeChapter?.id == chapter.id) _activeChapter = updated;
    });
  }

  Future<void> _deleteChapter(BookChapterFile chapter) async {
    final tr = Translations.of(context);
    final descendants = _descendantsOf(chapter.id);
    if (_chapters.length - descendants.length - 1 < 1) {
      _showMessage(tr.editor.chapterManager.atLeastOne);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.editor.chapterManager.deleteQuestion),
        content: Text(
          descendants.isEmpty
              ? tr.editor.chapterManager.deleteDescription(title: chapter.title)
              : tr.editor.chapterManager.deleteTreeDescription(title: chapter.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr.app.actions.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(tr.app.actions.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _saveNow(flushProject: false);
    await _historyService.createSnapshotIfChanged(
      project: widget.project,
      repository: widget.projectRepository,
      reason: 'beforeDelete',
      message: tr.editor.save.beforeDeleting(title: chapter.title),
    );

    final deletedIds = <String>{chapter.id, ...descendants.map((item) => item.id)};
    final activeDeleted = deletedIds.contains(_activeChapter?.id);
    await widget.projectRepository.deleteChapterTree(widget.project, chapter);
    final chapters = await widget.projectRepository.loadChapters(widget.project);
    if (!mounted) return;

    setState(() => _chapters = chapters);
    if (activeDeleted && chapters.isNotEmpty) {
      _activeChapter = null;
      await _selectChapter(chapters.first);
    }
  }

  List<BookChapterFile> _descendantsOf(String chapterId) {
    final result = <BookChapterFile>[];
    final pending = <String>{chapterId};
    var changed = true;
    while (changed) {
      changed = false;
      for (final chapter in _chapters) {
        if (chapter.parentId != null &&
            pending.contains(chapter.parentId) &&
            !pending.contains(chapter.id)) {
          pending.add(chapter.id);
          result.add(chapter);
          changed = true;
        }
      }
    }
    return result;
  }

  Future<void> _moveChapter(BookChapterFile chapter, int direction) async {
    final siblings = _chapters
        .where((item) => item.parentId == chapter.parentId)
        .toList(growable: false);
    final siblingIndex = siblings.indexWhere((item) => item.id == chapter.id);
    final targetSiblingIndex = siblingIndex + direction;
    if (siblingIndex < 0 ||
        targetSiblingIndex < 0 ||
        targetSiblingIndex >= siblings.length) {
      return;
    }

    final target = siblings[targetSiblingIndex];
    final from = _chapters.indexWhere((item) => item.id == chapter.id);
    final to = _chapters.indexWhere((item) => item.id == target.id);
    final reordered = List<BookChapterFile>.of(_chapters);
    reordered[from] = target;
    reordered[to] = chapter;
    setState(() => _chapters = reordered);
    await widget.projectRepository.reorderChapters(widget.project, reordered);
  }

  Future<void> _reorderChapters(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    if (oldIndex == newIndex) return;
    final reordered = List<BookChapterFile>.of(_chapters);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    setState(() => _chapters = reordered);
    await widget.projectRepository.reorderChapters(widget.project, reordered);
  }

  Future<String?> _askForChapterTitle({
    required String title,
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => _ChapterTitleDialog(
        title: title,
        initialValue: initialValue,
      ),
    );
  }

  Future<void> _showBookSettings() async {
    final tocEntries = [
      for (final chapter in _chapters)
        BookTocEntry(title: chapter.title, level: _depthOf(chapter)),
    ];
    final settings = await Navigator.of(context).push<BookSettings>(
      MaterialPageRoute(
        builder: (_) => BookSettingsPage(
          settings: _bookSettings,
          tocEntries: tocEntries,
        ),
      ),
    );
    if (settings == null || !mounted) return;

    await _saveNow(flushProject: false);
    await _historyService.createSnapshotIfChanged(
      project: widget.project,
      repository: widget.projectRepository,
      reason: 'settingsChanged',
      message: Translations.of(context).editor.save.beforeChangingSettings,
    );

    setState(() {
      _bookSettings = settings;
      _settingsInProgress = true;
      _errorMessage = null;
    });

    try {
      await widget.projectRepository.saveBookSettings(widget.project, settings);
      if (!_largeChapterPreviewPaused) {
        setState(() => _previewMarkdown = _draftMarkdown);
      }
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = Translations.of(context)
            .editor
            .save
            .errors
            .saveSettings(error: '$error');
      });
    } finally {
      if (mounted) setState(() => _settingsInProgress = false);
    }
  }

  Future<void> _openHistory() async {
    await _saveNow();
    if (!mounted || _saveStatus == SaveStatus.failed) return;
    final restored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookHistoryPage(
          project: widget.project,
          repository: widget.projectRepository,
        ),
      ),
    );
    if (restored == true && mounted) {
      setState(() => _saveStatus = SaveStatus.loading);
      await _loadBook();
    }
  }

  Future<void> _exportBook(BookOutputFormat format) async {
    if (_exportInProgress) return;
    if (format == BookOutputFormat.pdf && !_template.metadata.supportsPdf) return;
    if (format == BookOutputFormat.epub && !_template.metadata.supportsEpub) return;

    final extension = format == BookOutputFormat.pdf ? 'pdf' : 'epub';
    final location = await getSaveLocation(
      suggestedName:
          '${path.basenameWithoutExtension(widget.project.file.path)}.$extension',
      acceptedTypeGroups: <XTypeGroup>[
        XTypeGroup(label: extension.toUpperCase(), extensions: [extension]),
      ],
    );
    if (location == null) return;

    setState(() {
      _exportInProgress = true;
      _errorMessage = null;
    });
    try {
      await _saveNow();
      if (format == BookOutputFormat.pdf) {
        final markdown = await _compilationService.buildMarkdown(
          project: widget.project,
          repository: widget.projectRepository,
          template: _template,
          settings: _bookSettings,
        );
        final document = _template.parse(markdown, settings: _bookSettings);
        final bytes = await _template.buildPdf(document).save();
        await File(location.path).writeAsBytes(bytes, flush: true);
      } else {
        final bytes = await _exportService.buildEpub(
          project: widget.project,
          repository: widget.projectRepository,
          template: _template,
          settings: _bookSettings,
        );
        await File(location.path).writeAsBytes(bytes, flush: true);
      }
      if (!mounted) return;
      final label = format == BookOutputFormat.pdf ? 'PDF' : 'EPUB';
      _showMessage(
        Translations.of(context).editor.export.success(
              format: label,
              path: location.path,
            ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final label = format == BookOutputFormat.pdf ? 'PDF' : 'EPUB';
      setState(() {
        _errorMessage = Translations.of(context)
            .editor
            .export
            .failure(format: label, error: '$error');
      });
    } finally {
      if (mounted) setState(() => _exportInProgress = false);
    }
  }

  Future<void> _closeBook() async {
    _saveDebounce?.cancel();
    _previewDebounce?.cancel();
    _projectFlushDebounce?.cancel();
    await _saveNow();
    if (!mounted || _saveStatus == SaveStatus.failed) return;
    await widget.onClose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  int _depthOf(BookChapterFile chapter) {
    var depth = 1;
    var parentId = chapter.parentId;
    final visited = <String>{};
    while (parentId != null && visited.add(parentId)) {
      BookChapterFile? parent;
      for (final item in _chapters) {
        if (item.id == parentId) {
          parent = item;
          break;
        }
      }
      if (parent == null) break;
      depth++;
      parentId = parent.parentId;
    }
    return depth;
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final activeIndex = _chapters.indexWhere(
      (chapter) => chapter.id == _activeChapter?.id,
    );

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        toolbarHeight: 52,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: scheme.surfaceContainerLow,
        leading: IconButton(
          tooltip: tr.editor.sidebar.close,
          onPressed: _saveStatus == SaveStatus.loading ? null : _closeBook,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 17,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${_activeChapter?.title ?? tr.editor.chapterManager.loading} · '
                    '${_template.metadata.name} v${_template.metadata.version}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: tr.editor.sidebar.title,
            isSelected: _sidebarVisible,
            onPressed: () => setState(() => _sidebarVisible = !_sidebarVisible),
            icon: const Icon(Icons.view_sidebar_outlined),
            selectedIcon: const Icon(Icons.view_sidebar_rounded),
          ),
          if (_workspaceMode == BookWorkspaceMode.edit)
            IconButton(
              tooltip: tr.editor.workspace.modes.preview,
              isSelected: _previewVisible,
              onPressed: () => setState(() => _previewVisible = !_previewVisible),
              icon: const Icon(Icons.preview_outlined),
              selectedIcon: const Icon(Icons.preview_rounded),
            ),
          const SizedBox(width: 4),
          SegmentedButton<BookWorkspaceMode>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
            segments: [
              ButtonSegment(
                value: BookWorkspaceMode.edit,
                icon: const Icon(Icons.edit_outlined, size: 17),
                label: Text(tr.editor.workspace.modes.edit),
              ),
              ButtonSegment(
                value: BookWorkspaceMode.preview,
                icon: const Icon(Icons.visibility_outlined, size: 17),
                label: Text(tr.editor.workspace.modes.preview),
              ),
            ],
            selected: {_workspaceMode},
            onSelectionChanged: (selection) {
              setState(() {
                _workspaceMode = selection.first;
                if (_workspaceMode == BookWorkspaceMode.preview) {
                  _previewVisible = true;
                }
              });
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: tr.editor.sidebar.history.title,
            onPressed: _saveStatus == SaveStatus.loading ? null : _openHistory,
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: tr.editor.sidebar.settings.title,
            onPressed: _saveStatus == SaveStatus.loading || _settingsInProgress
                ? null
                : _showBookSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: tr.editor.sidebar.appSettings,
            onPressed: widget.onOpenAppSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          PopupMenuButton<BookOutputFormat>(
            tooltip: tr.editor.export.menu,
            enabled: _saveStatus != SaveStatus.loading && !_exportInProgress,
            onSelected: (format) => unawaited(_exportBook(format)),
            icon: _exportInProgress
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_outlined),
            itemBuilder: (context) => [
              if (_template.metadata.supportsPdf)
                PopupMenuItem(
                  value: BookOutputFormat.pdf,
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(tr.editor.export.pdf),
                  ),
                ),
              if (_template.metadata.supportsEpub)
                PopupMenuItem(
                  value: BookOutputFormat.epub,
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(tr.editor.export.epub),
                  ),
                ),
            ],
          ),
          IconButton(
            tooltip: tr.editor.save.now,
            onPressed: _saveStatus == SaveStatus.loading ? null : _saveNow,
            icon: const Icon(Icons.save_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            MaterialBanner(
              content: Text(_errorMessage!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: _saveNow,
                  child: Text(tr.app.actions.retry),
                ),
              ],
            ),
          Expanded(
            child: _saveStatus == SaveStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final sidebar = _BookSidebar(
                        chapters: _chapters,
                        activeChapterId: _activeChapter?.id,
                        depthOf: _depthOf,
                        onClose: () => setState(() => _sidebarVisible = false),
                        onOpenAppSettings: widget.onOpenAppSettings,
                        onOpenSettings: _showBookSettings,
                        onOpenHistory: _openHistory,
                        onAddChapter: () => _addChapter(),
                        onAddChild: (chapter) => _addChapter(parentId: chapter.id),
                        onSelectChapter: _selectChapter,
                        onRenameChapter: _renameChapter,
                        onDeleteChapter: _deleteChapter,
                        onMoveChapterUp: (chapter) => _moveChapter(chapter, -1),
                        onMoveChapterDown: (chapter) => _moveChapter(chapter, 1),
                        onReorder: _reorderChapters,
                      );
                      final editor = _EditorSurface(
                        title: _activeChapter?.title ?? tr.editor.workspace.markdown.title,
                        onClosePreview: _previewVisible
                            ? () => setState(() => _previewVisible = false)
                            : null,
                        child: _MarkdownEditor(
                          controller: _controller,
                          chapterTitle: _activeChapter?.title,
                          actions: _template.metadata.toolbarActions,
                          onChanged: _onMarkdownChanged,
                        ),
                      );
                      final previewContent = _largeChapterPreviewPaused
                          ? _LargeChapterPreviewPaused(
                              characters: _draftMarkdown.length,
                              onRefresh: () {
                                setState(() {
                                  _previewMarkdown = _draftMarkdown;
                                  _largeChapterPreviewPaused = false;
                                });
                              },
                            )
                          : BookPreviewPanel(
                              project: widget.project,
                              projectRepository: widget.projectRepository,
                              template: _template,
                              settings: _bookSettings,
                              chapterMarkdown: _previewMarkdown,
                              chapterTitle: _activeChapter?.title,
                              onBeforeFullBookPreview: () =>
                                  _saveNow(flushProject: false),
                            );
                      final preview = _PreviewSurface(
                        onClose: _workspaceMode == BookWorkspaceMode.edit
                            ? () => setState(() => _previewVisible = false)
                            : null,
                        child: previewContent,
                      );

                      final showSidebar = _sidebarVisible && constraints.maxWidth >= 780;
                      final showPreview = _workspaceMode == BookWorkspaceMode.preview ||
                          (_previewVisible && constraints.maxWidth >= 940);

                      return Row(
                        children: [
                          _ActivityRail(
                            sidebarVisible: showSidebar,
                            previewVisible: showPreview,
                            onToggleSidebar: () =>
                                setState(() => _sidebarVisible = !_sidebarVisible),
                            onTogglePreview: () => setState(() {
                              _previewVisible = !_previewVisible;
                              if (_previewVisible &&
                                  _workspaceMode == BookWorkspaceMode.preview) {
                                _workspaceMode = BookWorkspaceMode.edit;
                              }
                            }),
                            onOpenHistory: _openHistory,
                            onOpenSettings: _showBookSettings,
                            onOpenAppSettings: widget.onOpenAppSettings,
                          ),
                          const VerticalDivider(width: 1),
                          if (showSidebar) ...[
                            SizedBox(width: 286, child: sidebar),
                            const VerticalDivider(width: 1),
                          ],
                          if (_workspaceMode == BookWorkspaceMode.preview)
                            Expanded(child: preview)
                          else ...[
                            Expanded(child: editor),
                            if (showPreview) ...[
                              const VerticalDivider(width: 1),
                              Expanded(child: preview),
                            ],
                          ],
                        ],
                      );
                    },
                  ),
          ),
          _StatusBar(
            activeIndex: activeIndex,
            chapterCount: _chapters.length,
            templateName: _template.metadata.name,
            templateVersion: _template.metadata.version,
            saveStatus: _saveStatus,
            path: widget.project.file.path,
          ),
        ],
      ),
    );
  }
}

final class _ActivityRail extends StatelessWidget {
  const _ActivityRail({
    required this.sidebarVisible,
    required this.previewVisible,
    required this.onToggleSidebar,
    required this.onTogglePreview,
    required this.onOpenHistory,
    required this.onOpenSettings,
    required this.onOpenAppSettings,
  });

  final bool sidebarVisible;
  final bool previewVisible;
  final VoidCallback onToggleSidebar;
  final VoidCallback onTogglePreview;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenAppSettings;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget button({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
      bool selected = false,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: IconButton(
          tooltip: tooltip,
          isSelected: selected,
          onPressed: onPressed,
          style: IconButton.styleFrom(
            foregroundColor: selected ? scheme.primary : scheme.onSurfaceVariant,
            backgroundColor:
                selected ? scheme.primaryContainer.withValues(alpha: 0.55) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(icon, size: 21),
        ),
      );
    }

    return Material(
      color: scheme.surfaceContainerLowest,
      child: SizedBox(
        width: 50,
        child: Column(
          children: [
            const SizedBox(height: 6),
            button(
              icon: Icons.account_tree_outlined,
              tooltip: tr.editor.sidebar.title,
              onPressed: onToggleSidebar,
              selected: sidebarVisible,
            ),
            button(
              icon: Icons.preview_outlined,
              tooltip: tr.editor.workspace.modes.preview,
              onPressed: onTogglePreview,
              selected: previewVisible,
            ),
            button(
              icon: Icons.history_rounded,
              tooltip: tr.editor.sidebar.history.title,
              onPressed: onOpenHistory,
            ),
            button(
              icon: Icons.tune_rounded,
              tooltip: tr.editor.sidebar.settings.title,
              onPressed: onOpenSettings,
            ),
            const Spacer(),
            button(
              icon: Icons.settings_outlined,
              tooltip: tr.editor.sidebar.appSettings,
              onPressed: onOpenAppSettings,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

final class _EditorSurface extends StatelessWidget {
  const _EditorSurface({
    required this.title,
    required this.child,
    this.onClosePreview,
  });

  final String title;
  final Widget child;
  final VoidCallback? onClosePreview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Column(
        children: [
          Container(
            height: 38,
            padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (onClosePreview != null)
                  IconButton(
                    tooltip: Translations.of(context).editor.workspace.modes.preview,
                    onPressed: onClosePreview,
                    icon: const Icon(Icons.vertical_split_outlined, size: 17),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

final class _PreviewSurface extends StatelessWidget {
  const _PreviewSurface({required this.child, this.onClose});

  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Column(
        children: [
          Container(
            height: 38,
            padding: const EdgeInsetsDirectional.only(start: 14, end: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.preview_outlined, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tr.editor.workspace.modes.preview,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    tooltip: tr.app.actions.close,
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 17),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

final class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.activeIndex,
    required this.chapterCount,
    required this.templateName,
    required this.templateVersion,
    required this.saveStatus,
    required this.path,
  });

  final int activeIndex;
  final int chapterCount;
  final String templateName;
  final String templateVersion;
  final SaveStatus saveStatus;
  final String path;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: SizedBox(
        height: 28,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Icon(Icons.auto_stories_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              if (activeIndex >= 0)
                Text(
                  tr.editor.chapterManager.index(
                    current: activeIndex + 1,
                    total: chapterCount,
                  ),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              const SizedBox(width: 14),
              Text(
                '$templateName v$templateVersion',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              _SaveStatusView(status: saveStatus, path: path),
            ],
          ),
        ),
      ),
    );
  }
}

final class _MarkdownEditor extends StatelessWidget {
  const _MarkdownEditor({
    required this.controller,
    required this.chapterTitle,
    required this.actions,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? chapterTitle;
  final Set<TemplateToolbarAction> actions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapterTitle == null
                        ? tr.editor.workspace.markdown.title
                        : tr.editor.workspace.markdown.chapterTitle(
                            title: chapterTitle!,
                          ),
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: tr.editor.workspace.markdown.chapterOnlyLoaded,
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: MarkdownCommandToolbar(
                controller: controller,
                actions: actions,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: scheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: scheme.primary),
                  ),
                  hintText: tr.editor.workspace.markdown.writeHint,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14.5,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _BookSidebar extends StatelessWidget {
  const _BookSidebar({
    required this.chapters,
    required this.activeChapterId,
    required this.depthOf,
    required this.onClose,
    required this.onOpenAppSettings,
    required this.onOpenSettings,
    required this.onOpenHistory,
    required this.onAddChapter,
    required this.onAddChild,
    required this.onSelectChapter,
    required this.onRenameChapter,
    required this.onDeleteChapter,
    required this.onMoveChapterUp,
    required this.onMoveChapterDown,
    required this.onReorder,
  });

  final List<BookChapterFile> chapters;
  final String? activeChapterId;
  final int Function(BookChapterFile) depthOf;
  final VoidCallback onClose;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHistory;
  final VoidCallback onAddChapter;
  final ValueChanged<BookChapterFile> onAddChild;
  final ValueChanged<BookChapterFile> onSelectChapter;
  final ValueChanged<BookChapterFile> onRenameChapter;
  final ValueChanged<BookChapterFile> onDeleteChapter;
  final ValueChanged<BookChapterFile> onMoveChapterUp;
  final ValueChanged<BookChapterFile> onMoveChapterDown;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.editor.sidebar.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: tr.app.actions.close,
                    onPressed: onClose,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_left_rounded, size: 19),
                  ),
                ],
              ),
            ),
          ),
          _SidebarAction(
            icon: Icons.tune_outlined,
            title: tr.editor.sidebar.settings.title,
            subtitle: tr.editor.sidebar.settings.subtitle,
            onTap: onOpenSettings,
          ),
          _SidebarAction(
            icon: Icons.history_rounded,
            title: tr.editor.sidebar.history.title,
            subtitle: tr.editor.sidebar.history.subtitle,
            onTap: onOpenHistory,
          ),
          _SidebarAction(
            icon: Icons.settings_outlined,
            title: tr.editor.sidebar.appSettings,
            onTap: onOpenAppSettings,
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
          SizedBox(
            height: 42,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.editor.chapterManager.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            letterSpacing: 0.7,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    tooltip: tr.editor.chapterManager.add,
                    onPressed: onAddChapter,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_rounded, size: 19),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
              buildDefaultDragHandles: false,
              itemCount: chapters.length,
              onReorder: (oldIndex, newIndex) {
                unawaited(onReorder(oldIndex, newIndex));
              },
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final depth = depthOf(chapter);
                final selected = chapter.id == activeChapterId;
                return Padding(
                  key: ValueKey(chapter.id),
                  padding: EdgeInsetsDirectional.only(start: (depth - 1) * 14.0),
                  child: Material(
                    color: selected
                        ? scheme.primaryContainer.withValues(alpha: 0.45)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      dense: true,
                      minTileHeight: 42,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selected: selected,
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          depth == 1
                              ? Icons.description_outlined
                              : Icons.subdirectory_arrow_right_rounded,
                          size: 18,
                          color: selected ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: selected ? FontWeight.w600 : null,
                            ),
                      ),
                      onTap: () => onSelectChapter(chapter),
                      trailing: PopupMenuButton<String>(
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        onSelected: (value) {
                          switch (value) {
                            case 'child':
                              onAddChild(chapter);
                            case 'rename':
                              onRenameChapter(chapter);
                            case 'up':
                              onMoveChapterUp(chapter);
                            case 'down':
                              onMoveChapterDown(chapter);
                            case 'delete':
                              onDeleteChapter(chapter);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'child',
                            child: Text(tr.editor.chapterManager.addChild),
                          ),
                          PopupMenuItem(
                            value: 'rename',
                            child: Text(tr.editor.chapterManager.rename),
                          ),
                          PopupMenuItem(
                            value: 'up',
                            child: Text(tr.editor.chapterManager.moveUp),
                          ),
                          PopupMenuItem(
                            value: 'down',
                            child: Text(tr.editor.chapterManager.moveDown),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text(tr.app.actions.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _SidebarAction extends StatelessWidget {
  const _SidebarAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      child: ListTile(
        minTileHeight: 44,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        title: Text(title),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: onTap,
      ),
    );
  }
}

final class _ChapterTitleDialog extends StatefulWidget {
  const _ChapterTitleDialog({
    required this.title,
    this.initialValue,
  });

  final String title;
  final String? initialValue;

  @override
  State<_ChapterTitleDialog> createState() => _ChapterTitleDialogState();
}

final class _ChapterTitleDialogState extends State<_ChapterTitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.of(context).pop(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: tr.dialogs.chapterTitle.fieldLabel,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr.app.actions.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(tr.app.actions.save),
        ),
      ],
    );
  }
}

final class _LargeChapterPreviewPaused extends StatelessWidget {
  const _LargeChapterPreviewPaused({
    required this.characters,
    required this.onRefresh,
  });

  final int characters;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_outline_rounded, size: 44),
                const SizedBox(height: 14),
                Text(
                  tr.editor.previewPanel.largeChapter.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${tr.editor.previewPanel.largeChapter.characters(count: characters)}. '
                  '${tr.editor.previewPanel.largeChapter.description}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(tr.editor.previewPanel.largeChapter.renderOnce),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _SaveStatusView extends StatelessWidget {
  const _SaveStatusView({required this.status, required this.path});

  final SaveStatus status;
  final String path;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, label) = switch (status) {
      SaveStatus.loading => (Icons.hourglass_empty_rounded, tr.app.status.loading),
      SaveStatus.saving => (Icons.sync_rounded, tr.app.status.saving),
      SaveStatus.saved => (Icons.check_circle_outline_rounded, tr.app.status.saved),
      SaveStatus.failed => (Icons.error_outline_rounded, tr.app.status.saveFailed),
    };

    return Tooltip(
      message: path,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
