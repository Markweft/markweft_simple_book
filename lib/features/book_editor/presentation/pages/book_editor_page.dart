import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/features/book_editor/application/template_registry.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/book_settings_dialog.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/markdown_command_toolbar.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;

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

enum SaveStatus { loading, saved, saving, failed }

final class _BookEditorPageState extends State<BookEditorPage> {
  static const int _livePreviewCharacterLimit = 350000;
  static const XTypeGroup _pdfType = XTypeGroup(
    label: 'PDF document',
    extensions: <String>['pdf'],
  );

  late final TextEditingController _controller;
  Timer? _saveDebounce;
  Timer? _previewDebounce;
  Timer? _projectFlushDebounce;

  List<BookChapterFile> _chapters = const <BookChapterFile>[];
  BookChapterFile? _activeChapter;
  BookSettings _bookSettings = const BookSettings();
  String _draftMarkdown = '';
  String _previewMarkdown = '';
  String? _pendingMarkdown;
  String? _errorMessage;
  bool _saveInProgress = false;
  bool _pdfInProgress = false;
  bool _settingsInProgress = false;
  bool _largeChapterPreviewPaused = false;
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;

  BookTemplate get _template => TemplateRegistry.resolve(
        _bookSettings.templateId,
      );

  BookDocument get _activeDocument => _template.parse(
        _previewMarkdown,
        settings: _bookSettings,
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
          title: 'Chapter One',
        );
        chapters = await widget.projectRepository.loadChapters(widget.project);
      }

      final firstChapter = chapters.first;
      final markdown = await widget.projectRepository.loadChapterMarkdown(
        widget.project,
        firstChapter,
      );
      if (!mounted) return;

      _controller.text = markdown;
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
        _errorMessage = 'Unable to load this book: $error';
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
          _errorMessage = 'Unable to save this chapter: $error';
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
        _errorMessage = 'Chapter saved locally, but .mdw update failed: $error';
      });
    }
  }

  Future<void> _saveNow({bool flushProject = true}) async {
    _saveDebounce?.cancel();
    setState(() => _saveStatus = SaveStatus.saving);
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
        _errorMessage = 'Unable to open chapter: $error';
      });
    }
  }

  Future<void> _addChapter() async {
    final titleController = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add chapter'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Chapter title',
            hintText: 'Chapter Two',
          ),
          onSubmitted: (value) {
            final title = value.trim();
            if (title.isNotEmpty) Navigator.of(context).pop(title);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) Navigator.of(context).pop(title);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    titleController.dispose();
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

  Future<void> _showBookSettings() async {
    final settings = await showDialog<BookSettings>(
      context: context,
      builder: (_) => BookSettingsDialog(settings: _bookSettings),
    );
    if (settings == null || !mounted) return;

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
      setState(() => _errorMessage = 'Unable to save book settings: $error');
    } finally {
      if (mounted) setState(() => _settingsInProgress = false);
    }
  }

  void _refreshLargeChapterPreview() {
    setState(() {
      _previewMarkdown = _draftMarkdown;
      _largeChapterPreviewPaused = false;
    });
  }

  Future<void> _exportPdf() async {
    if (_pdfInProgress) return;

    final location = await getSaveLocation(
      suggestedName:
          '${path.basenameWithoutExtension(widget.project.file.path)}.pdf',
      acceptedTypeGroups: const <XTypeGroup>[_pdfType],
    );
    if (location == null) return;

    setState(() {
      _pdfInProgress = true;
      _errorMessage = null;
    });

    try {
      await _saveNow();
      final markdown = await widget.projectRepository.loadWholeBookMarkdown(
        widget.project,
      );
      final document = _template.parse(markdown, settings: _bookSettings);
      final bytes = await _template.buildPdf(document).save();
      await File(location.path).writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported to ${location.path}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to export PDF: $error');
    } finally {
      if (mounted) setState(() => _pdfInProgress = false);
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

  @override
  Widget build(BuildContext context) {
    final activeIndex = _chapters.indexWhere(
      (chapter) => chapter.id == _activeChapter?.id,
    );
    final document = _largeChapterPreviewPaused ? null : _activeDocument;
    final pageCount = document?.pages.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close book',
          onPressed: _saveStatus == SaveStatus.loading ? null : _closeBook,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project.title),
            Text(
              '${_activeChapter?.title ?? 'Loading chapter'} · '
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
                'Chapter ${activeIndex + 1}/${_chapters.length}'
                '${pageCount == null ? '' : ' · $pageCount pages'}',
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Book settings',
            onPressed: _saveStatus == SaveStatus.loading || _settingsInProgress
                ? null
                : _showBookSettings,
            icon: _settingsInProgress
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Add chapter',
            onPressed: _saveStatus == SaveStatus.loading ? null : _addChapter,
            icon: const Icon(Icons.library_add_outlined),
          ),
          IconButton(
            tooltip: 'Export PDF',
            onPressed: _saveStatus == SaveStatus.loading || _pdfInProgress
                ? null
                : _exportPdf,
            icon: _pdfInProgress
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
          ),
          IconButton(
            tooltip: 'Save now',
            onPressed: _saveStatus == SaveStatus.loading ? null : _saveNow,
            icon: const Icon(Icons.save_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
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
                TextButton(onPressed: _saveNow, child: const Text('Retry')),
              ],
            ),
          Expanded(
            child: _saveStatus == SaveStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
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
                          : _TemplatePreview(
                              template: _template,
                              document: document!,
                            );
                      final chapters = _ChapterSidebar(
                        chapters: _chapters,
                        activeChapterId: _activeChapter?.id,
                        onAddChapter: _addChapter,
                        onSelectChapter: _selectChapter,
                      );

                      if (constraints.maxWidth >= 1200) {
                        return Row(
                          children: [
                            SizedBox(width: 250, child: chapters),
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
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapterTitle == null ? 'Markdown' : 'Markdown · $chapterTitle',
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Tooltip(
                  message: 'Only this chapter is loaded into the editor.',
                  child: Icon(Icons.speed_outlined, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownCommandToolbar(controller: controller, onChanged: onChanged),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Write this chapter in Markdown...',
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

final class _ChapterSidebar extends StatelessWidget {
  const _ChapterSidebar({
    required this.chapters,
    required this.activeChapterId,
    required this.onAddChapter,
    required this.onSelectChapter,
  });

  final List<BookChapterFile> chapters;
  final String? activeChapterId;
  final VoidCallback onAddChapter;
  final ValueChanged<BookChapterFile> onSelectChapter;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Text('Chapters', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                IconButton(
                  tooltip: 'Add chapter',
                  onPressed: onAddChapter,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                return ListTile(
                  dense: true,
                  selected: chapter.id == activeChapterId,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    chapter.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(chapter.fileName),
                  onTap: () => onSelectChapter(chapter),
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
    return ColoredBox(
      color: const Color(0xFFE8E3DB),
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
                  'Live preview paused for this large chapter',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$characters characters. Editing and autosave stay active; '
                  'preview parsing is paused to keep the UI responsive.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Render preview once'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({
    required this.template,
    required this.document,
  });

  final BookTemplate template;
  final BookDocument document;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8E3DB),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${template.metadata.name} · current chapter · '
                    '${document.pages.length} pages',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: template.buildDocument(document)),
        ],
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
    final (icon, label) = switch (status) {
      SaveStatus.loading => (Icons.hourglass_empty, 'Loading'),
      SaveStatus.saving => (Icons.sync, 'Saving...'),
      SaveStatus.saved => (Icons.check_circle_outline, 'Saved'),
      SaveStatus.failed => (Icons.error_outline, 'Save failed'),
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
