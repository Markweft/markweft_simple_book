import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
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
import 'package:markweft_simple_book/i18n/strings.g.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;

enum SaveStatus { loading, saved, saving, failed }

final class BookEditorPage extends StatefulWidget {
  const BookEditorPage({
    required this.project,
    required this.projectRepository,
    required this.onClose,
    super.key,
  });

  final MarkweftProject project;
  final BookProjectRepository projectRepository;
  final Future<void> Function() onClose;

  @override
  State<BookEditorPage> createState() => _BookEditorPageState();
}

final class _BookEditorPageState extends State<BookEditorPage> {
  static const int _livePreviewCharacterLimit = 350000;
  static const BookExportService _exportService = BookExportService();
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
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;

  BookTemplate get _template => TemplateRegistry.resolve(
        _bookSettings.templateId,
      );

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
      final settings = await widget.projectRepository.loadBookSettings(
        widget.project,
      );
      var chapters = await widget.projectRepository.loadChapters(widget.project);

      if (chapters.isEmpty) {
        await widget.projectRepository.createChapter(
          widget.project,
          title: t.editor.chapterOne,
        );
        chapters = await widget.projectRepository.loadChapters(widget.project);
      }

      final firstChapter = chapters.first;
      final markdown = await widget.projectRepository.loadChapterMarkdown(
        widget.project,
        firstChapter,
      );
      if (!mounted) return;

      _controller.value = TextEditingValue(
        text: markdown,
        selection: const TextSelection.collapsed(offset: 0),
      );
      setState(() {
        _bookSettings = settings;
        _chapters = chapters;
        _activeChapter = firstChapter;
        _setLoadedMarkdown(markdown);
        _saveStatus = SaveStatus.saved;
        _errorMessage = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _saveStatus = SaveStatus.failed;
        _errorMessage = t.editor.loadBookFailed(error: '$error');
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
          if (!mounted) return;
          setState(() => _previewMarkdown = _draftMarkdown);
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
        message: t.editor.automaticRecoveryCheckpoint,
        enforceRecoveryInterval: true,
      );
      unawaited(
        _historyService.pruneRecoveryVersions(widget.project),
      );

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
          _errorMessage = t.editor.saveChapterFailed(error: '$error');
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
        _errorMessage = t.editor.mdwFlushFailed(error: '$error');
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

  Future<void> _saveBeforeFullBookPreview() {
    return _saveNow(flushProject: false);
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
        _errorMessage = t.editor.openChapterFailed(error: '$error');
      });
    }
  }

  Future<void> _addChapter() async {
    final title = await _askForChapterTitle(title: t.editor.addChapter);
    if (title == null || !mounted) return;

    await _saveNow(flushProject: false);
    final chapter = await widget.projectRepository.createChapter(
      widget.project,
      title: title,
    );
    final chapters = await widget.projectRepository.loadChapters(widget.project);
    if (!mounted) return;
    setState(() => _chapters = chapters);
    await _selectChapter(chapter);
  }

  Future<void> _renameChapter(BookChapterFile chapter) async {
    final title = await _askForChapterTitle(
      title: t.editor.renameChapter,
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
    if (_chapters.length <= 1) {
      _showMessage(tr.editor.atLeastOneChapter);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.editor.deleteChapterQuestion),
        content: Text(
          tr.editor.deleteChapterDescription(title: chapter.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr.app.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(tr.app.delete),
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
      message: tr.editor.beforeDeleting(title: chapter.title),
    );

    final deletedActive = _activeChapter?.id == chapter.id;
    await widget.projectRepository.deleteChapter(widget.project, chapter);
    final chapters = await widget.projectRepository.loadChapters(widget.project);
    if (!mounted) return;

    setState(() => _chapters = chapters);
    if (deletedActive && chapters.isNotEmpty) {
      _activeChapter = null;
      await _selectChapter(chapters.first);
    }
  }

  Future<void> _moveChapter(BookChapterFile chapter, int direction) async {
    final index = _chapters.indexWhere((item) => item.id == chapter.id);
    final target = index + direction;
    if (index < 0 || target < 0 || target >= _chapters.length) return;

    final reordered = List<BookChapterFile>.of(_chapters);
    final moved = reordered.removeAt(index);
    reordered.insert(target, moved);
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
  }) async {
    final controller = TextEditingController(text: initialValue);
    final tr = Translations.of(context);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: tr.dialogs.chapterTitle),
          onSubmitted: (value) {
            final text = value.trim();
            if (text.isNotEmpty) Navigator.of(context).pop(text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr.app.cancel),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) Navigator.of(context).pop(text);
            },
            child: Text(tr.app.save),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showBookSettings() async {
    final settings = await Navigator.of(context).push<BookSettings>(
      MaterialPageRoute(
        builder: (_) => BookSettingsPage(settings: _bookSettings),
      ),
    );
    if (settings == null || !mounted) return;

    await _saveNow(flushProject: false);
    await _historyService.createSnapshotIfChanged(
      project: widget.project,
      repository: widget.projectRepository,
      reason: 'settingsChanged',
      message: t.editor.beforeChangingSettings,
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
      setState(() => _errorMessage = t.editor.saveSettingsFailed(error: '$error'));
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

  void _refreshLargeChapterPreview() {
    setState(() {
      _previewMarkdown = _draftMarkdown;
      _largeChapterPreviewPaused = false;
    });
  }

  Future<void> _exportBook(BookOutputFormat format) async {
    if (_exportInProgress) return;

    final baseName = path.basenameWithoutExtension(widget.project.file.path);
    final extension = switch (format) {
      BookOutputFormat.pdf => 'pdf',
      BookOutputFormat.epub => 'epub',
    };
    final typeGroup = XTypeGroup(
      label: format == BookOutputFormat.pdf ? t.editor.pdf : t.editor.epub,
      extensions: <String>[extension],
    );

    final location = await getSaveLocation(
      suggestedName: '$baseName.$extension',
      acceptedTypeGroups: <XTypeGroup>[typeGroup],
    );
    if (location == null) return;

    setState(() {
      _exportInProgress = true;
      _errorMessage = null;
    });

    try {
      await _saveNow();

      if (format == BookOutputFormat.pdf) {
        final markdown = await widget.projectRepository.loadWholeBookMarkdown(
          widget.project,
        );
        final document = _template.parse(
          markdown,
          settings: _bookSettings,
        );
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
      final formatLabel = format == BookOutputFormat.pdf ? t.editor.pdf : t.editor.epub;
      _showMessage(
        t.editor.exported(format: formatLabel, path: location.path),
      );
    } on Object catch (error) {
      if (!mounted) return;
      final formatLabel = format == BookOutputFormat.pdf ? t.editor.pdf : t.editor.epub;
      setState(() {
        _errorMessage = t.editor.exportFailed(
          format: formatLabel,
          error: '$error',
        );
      });
    } finally {
      if (mounted) setState(() => _exportInProgress = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _closeBook() async {
    _saveDebounce?.cancel();
    _previewDebounce?.cancel();
    _projectFlushDebounce?.cancel();
    await _saveNow();
    if (!mounted || _saveStatus == SaveStatus.failed) return;
    await widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final activeIndex = _chapters.indexWhere(
      (chapter) => chapter.id == _activeChapter?.id,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr.editor.closeBook,
          onPressed: _saveStatus == SaveStatus.loading ? null : _closeBook,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project.title),
            Text(
              '${_activeChapter?.title ?? tr.editor.loadingChapter} · '
              '${_template.metadata.name} v${_template.metadata.version}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          if (activeIndex >= 0)
            Center(
              child: Text(
                tr.editor.chapterIndex(
                  current: activeIndex + 1,
                  total: _chapters.length,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Center(
            child: SegmentedButton<BookWorkspaceMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: BookWorkspaceMode.edit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(tr.editor.edit),
                ),
                ButtonSegment(
                  value: BookWorkspaceMode.preview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(tr.editor.preview),
                ),
              ],
              selected: {_workspaceMode},
              onSelectionChanged: (selection) {
                setState(() => _workspaceMode = selection.first);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: tr.editor.versionHistory,
            onPressed: _saveStatus == SaveStatus.loading ? null : _openHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: tr.editor.bookSettings,
            onPressed: _saveStatus == SaveStatus.loading || _settingsInProgress
                ? null
                : _showBookSettings,
            icon: const Icon(Icons.tune),
          ),
          PopupMenuButton<BookOutputFormat>(
            tooltip: tr.editor.exportBook,
            enabled: _saveStatus != SaveStatus.loading && !_exportInProgress,
            onSelected: (format) => unawaited(_exportBook(format)),
            icon: _exportInProgress
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share_outlined),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: BookOutputFormat.pdf,
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(tr.editor.exportPdf),
                ),
              ),
              PopupMenuItem(
                value: BookOutputFormat.epub,
                child: ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(tr.editor.exportEpub),
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: tr.editor.saveNow,
            onPressed: _saveStatus == SaveStatus.loading ? null : _saveNow,
            icon: const Icon(Icons.save_outlined),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: _SaveStatusView(
              status: _saveStatus,
              path: widget.project.file.path,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null)
            MaterialBanner(
              content: Text(_errorMessage!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(onPressed: _saveNow, child: Text(tr.app.retry)),
              ],
            ),
          Expanded(
            child: _saveStatus == SaveStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final sidebar = _BookSectionsSidebar(
                        chapters: _chapters,
                        activeChapterId: _activeChapter?.id,
                        onOpenSettings: _showBookSettings,
                        onOpenHistory: _openHistory,
                        onAddChapter: _addChapter,
                        onSelectChapter: _selectChapter,
                        onRenameChapter: _renameChapter,
                        onDeleteChapter: _deleteChapter,
                        onMoveChapterUp: (chapter) => _moveChapter(chapter, -1),
                        onMoveChapterDown: (chapter) => _moveChapter(chapter, 1),
                        onReorder: _reorderChapters,
                      );

                      final editor = _MarkdownEditor(
                        controller: _controller,
                        chapterTitle: _activeChapter?.title,
                        onChanged: _onMarkdownChanged,
                      );

                      final preview = _largeChapterPreviewPaused
                          ? _LargeChapterPreviewPaused(
                              characters: _draftMarkdown.length,
                              onRefresh: _refreshLargeChapterPreview,
                            )
                          : BookPreviewPanel(
                              project: widget.project,
                              projectRepository: widget.projectRepository,
                              template: _template,
                              settings: _bookSettings,
                              chapterMarkdown: _previewMarkdown,
                              chapterTitle: _activeChapter?.title,
                              onBeforeFullBookPreview: _saveBeforeFullBookPreview,
                            );

                      if (_workspaceMode == BookWorkspaceMode.preview) {
                        if (constraints.maxWidth >= 980) {
                          return Row(
                            children: [
                              SizedBox(width: 280, child: sidebar),
                              const VerticalDivider(width: 1),
                              Expanded(child: preview),
                            ],
                          );
                        }
                        return preview;
                      }

                      if (constraints.maxWidth >= 1180) {
                        return Row(
                          children: [
                            SizedBox(width: 280, child: sidebar),
                            const VerticalDivider(width: 1),
                            Expanded(child: editor),
                            const VerticalDivider(width: 1),
                            Expanded(child: preview),
                          ],
                        );
                      }

                      if (constraints.maxWidth >= 900) {
                        return Row(
                          children: [
                            Expanded(child: editor),
                            const VerticalDivider(width: 1),
                            Expanded(child: preview),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Expanded(child: editor),
                          const Divider(height: 1),
                          Expanded(child: preview),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

final class _MarkdownEditor extends StatelessWidget {
  const _MarkdownEditor({
    required this.controller,
    required this.chapterTitle,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String? chapterTitle;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapterTitle == null
                        ? tr.editor.markdown
                        : tr.editor.markdownChapter(title: chapterTitle!),
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tooltip(
                  message: tr.editor.chapterOnlyLoaded,
                  child: const Icon(Icons.speed_outlined, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MarkdownCommandToolbar(
              controller: controller,
              onChanged: onChanged,
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
                  border: const OutlineInputBorder(),
                  hintText: tr.editor.writeChapterHint,
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _BookSectionsSidebar extends StatelessWidget {
  const _BookSectionsSidebar({
    required this.chapters,
    required this.activeChapterId,
    required this.onOpenSettings,
    required this.onOpenHistory,
    required this.onAddChapter,
    required this.onSelectChapter,
    required this.onRenameChapter,
    required this.onDeleteChapter,
    required this.onMoveChapterUp,
    required this.onMoveChapterDown,
    required this.onReorder,
  });

  final List<BookChapterFile> chapters;
  final String? activeChapterId;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenHistory;
  final VoidCallback onAddChapter;
  final ValueChanged<BookChapterFile> onSelectChapter;
  final ValueChanged<BookChapterFile> onRenameChapter;
  final ValueChanged<BookChapterFile> onDeleteChapter;
  final ValueChanged<BookChapterFile> onMoveChapterUp;
  final ValueChanged<BookChapterFile> onMoveChapterDown;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(tr.editor.book, style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.tune_outlined),
            title: Text(tr.editor.bookSettings),
            subtitle: Text(tr.editor.bookSettingsSubtitle),
            onTap: onOpenSettings,
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.history),
            title: Text(tr.editor.versionHistory),
            subtitle: Text(tr.editor.versionHistorySubtitle),
            onTap: onOpenHistory,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    tr.editor.chapters,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: tr.editor.addChapter,
                  onPressed: onAddChapter,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: chapters.length,
              onReorder: (oldIndex, newIndex) {
                unawaited(onReorder(oldIndex, newIndex));
              },
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  key: ValueKey(chapter.id),
                  dense: true,
                  selected: chapter.id == activeChapterId,
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_indicator),
                  ),
                  title: Text(
                    chapter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(tr.editor.chapterNumber(number: index + 1)),
                  onTap: () => onSelectChapter(chapter),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') {
                        onRenameChapter(chapter);
                      } else if (value == 'up') {
                        onMoveChapterUp(chapter);
                      } else if (value == 'down') {
                        onMoveChapterDown(chapter);
                      } else if (value == 'delete') {
                        onDeleteChapter(chapter);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(tr.editor.rename),
                      ),
                      if (index > 0)
                        PopupMenuItem(
                          value: 'up',
                          child: Text(tr.editor.moveUp),
                        ),
                      if (index < chapters.length - 1)
                        PopupMenuItem(
                          value: 'down',
                          child: Text(tr.editor.moveDown),
                        ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(tr.app.delete),
                      ),
                    ],
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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_outline, size: 42),
                const SizedBox(height: 16),
                Text(
                  tr.editor.largePreviewPaused,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${tr.editor.characters(count: characters)}. '
                  '${tr.editor.previewPausedDetails}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(tr.editor.renderOnce),
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
  const _SaveStatusView({
    required this.status,
    required this.path,
  });

  final SaveStatus status;
  final String path;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final (icon, label) = switch (status) {
      SaveStatus.loading => (Icons.hourglass_empty, tr.app.loading),
      SaveStatus.saving => (Icons.sync, tr.app.saving),
      SaveStatus.saved => (Icons.check_circle_outline, tr.app.saved),
      SaveStatus.failed => (Icons.error_outline, tr.app.saveFailed),
    };

    return Tooltip(
      message: path,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
