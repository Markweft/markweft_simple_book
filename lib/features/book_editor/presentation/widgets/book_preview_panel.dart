import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/features/book_assets/presentation/book_asset_collection_dialog.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_compilation_service.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_output_format.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/visual_book_canvas.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

enum _PreviewSurfaceMode { canvas, output }

final class BookPreviewPanel extends StatefulWidget {
  const BookPreviewPanel({
    required this.project,
    required this.projectRepository,
    required this.template,
    required this.settings,
    required this.chapterMarkdown,
    required this.chapterTitle,
    required this.onBeforeFullBookPreview,
    this.initialFormat = BookOutputFormat.pdf,
    this.initialScope = BookPreviewScope.chapter,
    super.key,
  });

  final MarkweftProject project;
  final BookProjectRepository projectRepository;
  final BookTemplate template;
  final BookSettings settings;
  final String chapterMarkdown;
  final String? chapterTitle;
  final Future<void> Function() onBeforeFullBookPreview;
  final BookOutputFormat initialFormat;
  final BookPreviewScope initialScope;

  @override
  State<BookPreviewPanel> createState() => _BookPreviewPanelState();
}

final class _BookPreviewPanelState extends State<BookPreviewPanel> {
  static const BookCompilationService _compilationService =
      BookCompilationService();

  late BookOutputFormat _format;
  late BookPreviewScope _scope;
  _PreviewSurfaceMode _surface = _PreviewSurfaceMode.canvas;
  String? _wholeBookMarkdown;
  bool _loadingWholeBook = false;
  Object? _wholeBookError;

  List<BookOutputFormat> get _supportedFormats {
    final formats = <BookOutputFormat>[];
    if (widget.template.metadata.supportsPdf) formats.add(BookOutputFormat.pdf);
    if (widget.template.metadata.supportsEpub) formats.add(BookOutputFormat.epub);
    return formats;
  }

  @override
  void initState() {
    super.initState();
    final supported = _supportedFormats;
    _format = supported.contains(widget.initialFormat)
        ? widget.initialFormat
        : supported.first;
    _scope = widget.initialScope;
    if (_scope == BookPreviewScope.book) {
      _scheduleWholeBookLoad();
    }
  }

  @override
  void didUpdateWidget(covariant BookPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final supported = _supportedFormats;
    if (!supported.contains(_format) && supported.isNotEmpty) {
      _format = supported.first;
    }
    if (oldWidget.project.file.path != widget.project.file.path ||
        oldWidget.settings != widget.settings ||
        oldWidget.template.metadata.id != widget.template.metadata.id) {
      _wholeBookMarkdown = null;
      _wholeBookError = null;
      if (_scope == BookPreviewScope.book) {
        _scheduleWholeBookLoad();
      }
    }
  }

  void _scheduleWholeBookLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scope != BookPreviewScope.book) return;
      unawaited(_loadWholeBook());
    });
  }

  Future<void> _setScope(BookPreviewScope scope) async {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    if (scope == BookPreviewScope.book) await _loadWholeBook();
  }

  Future<void> _loadWholeBook() async {
    if (_loadingWholeBook) return;
    setState(() {
      _loadingWholeBook = true;
      _wholeBookError = null;
    });
    try {
      await widget.onBeforeFullBookPreview();
      final markdown = await _compilationService.buildMarkdown(
        project: widget.project,
        repository: widget.projectRepository,
        template: widget.template,
        settings: widget.settings,
      );
      if (!mounted) return;
      setState(() => _wholeBookMarkdown = markdown);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _wholeBookError = error);
    } finally {
      if (mounted) setState(() => _loadingWholeBook = false);
    }
  }

  Future<void> _openAssets() async {
    final markdown = await showDialog<String>(
      context: context,
      builder: (context) => BookAssetCollectionDialog(
        project: widget.project,
        repository: widget.projectRepository,
      ),
    );
    if (markdown == null || !mounted) return;
    await Clipboard.setData(ClipboardData(text: markdown));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Asset Markdown copied. Paste it into the chapter editor.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markdown = _scope == BookPreviewScope.chapter
        ? widget.chapterMarkdown
        : _wholeBookMarkdown;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          _PreviewToolbar(
            surface: _surface,
            supportedFormats: _supportedFormats,
            format: _format,
            scope: _scope,
            chapterTitle: widget.chapterTitle,
            loading: _loadingWholeBook,
            onSurfaceChanged: (value) => setState(() => _surface = value),
            onFormatChanged: (value) => setState(() => _format = value),
            onScopeChanged: _setScope,
            onAssets: _openAssets,
            onOpenCurrentChapter: _scope == BookPreviewScope.book
                ? () => unawaited(_setScope(BookPreviewScope.chapter))
                : null,
            onRefresh: _scope == BookPreviewScope.book ? _loadWholeBook : null,
          ),
          const Divider(height: 1),
          Expanded(child: _buildBody(markdown)),
        ],
      ),
    );
  }

  Widget _buildBody(String? markdown) {
    final tr = Translations.of(context);
    if (_scope == BookPreviewScope.book && _loadingWholeBook && markdown == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_wholeBookError != null && _scope == BookPreviewScope.book) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 42),
              const SizedBox(height: 12),
              Text(tr.editor.previewPanel.loadFullBookFailed),
              const SizedBox(height: 8),
              Text('$_wholeBookError', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadWholeBook,
                icon: const Icon(Icons.refresh),
                label: Text(tr.app.actions.retry),
              ),
            ],
          ),
        ),
      );
    }

    final source = markdown ?? '';
    if (_surface == _PreviewSurfaceMode.canvas) {
      return VisualBookCanvas(
        template: widget.template,
        settings: widget.settings,
        markdown: source,
        chapterTitle:
            _scope == BookPreviewScope.chapter ? widget.chapterTitle : null,
      );
    }

    return switch (_format) {
      BookOutputFormat.pdf => _PdfPreview(
          template: widget.template,
          settings: widget.settings,
          markdown: source,
        ),
      BookOutputFormat.epub => _EpubPreview(markdown: source),
    };
  }
}

final class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.surface,
    required this.supportedFormats,
    required this.format,
    required this.scope,
    required this.chapterTitle,
    required this.loading,
    required this.onSurfaceChanged,
    required this.onFormatChanged,
    required this.onScopeChanged,
    required this.onAssets,
    required this.onOpenCurrentChapter,
    required this.onRefresh,
  });

  final _PreviewSurfaceMode surface;
  final List<BookOutputFormat> supportedFormats;
  final BookOutputFormat format;
  final BookPreviewScope scope;
  final String? chapterTitle;
  final bool loading;
  final ValueChanged<_PreviewSurfaceMode> onSurfaceChanged;
  final ValueChanged<BookOutputFormat> onFormatChanged;
  final Future<void> Function(BookPreviewScope) onScopeChanged;
  final VoidCallback onAssets;
  final VoidCallback? onOpenCurrentChapter;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<_PreviewSurfaceMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: _PreviewSurfaceMode.canvas,
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: Text(tr.editor.workspace.modes.canvas),
              ),
              ButtonSegment(
                value: _PreviewSurfaceMode.output,
                icon: const Icon(Icons.visibility_outlined),
                label: Text(tr.editor.workspace.modes.preview),
              ),
            ],
            selected: {surface},
            onSelectionChanged: (selection) =>
                onSurfaceChanged(selection.first),
          ),
          if (surface == _PreviewSurfaceMode.output) ...[
            if (supportedFormats.length > 1)
              SegmentedButton<BookOutputFormat>(
                showSelectedIcon: false,
                segments: [
                  for (final value in supportedFormats)
                    ButtonSegment(
                      value: value,
                      icon: Icon(
                        value == BookOutputFormat.pdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.menu_book_outlined,
                      ),
                      label: Text(
                        value == BookOutputFormat.pdf
                            ? tr.editor.previewPanel.format.pdf
                            : tr.editor.previewPanel.format.epub,
                      ),
                    ),
                ],
                selected: {format},
                onSelectionChanged: (selection) =>
                    onFormatChanged(selection.first),
              )
            else if (supportedFormats.isNotEmpty)
              Chip(
                avatar: Icon(
                  supportedFormats.first == BookOutputFormat.pdf
                      ? Icons.picture_as_pdf_outlined
                      : Icons.menu_book_outlined,
                  size: 17,
                ),
                label: Text(
                  supportedFormats.first == BookOutputFormat.pdf
                      ? tr.editor.previewPanel.format.pdf
                      : tr.editor.previewPanel.format.epub,
                ),
              ),
          ],
          SegmentedButton<BookPreviewScope>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: BookPreviewScope.chapter,
                icon: const Icon(Icons.article_outlined),
                label: Text(tr.editor.previewPanel.scope.chapter),
              ),
              ButtonSegment(
                value: BookPreviewScope.book,
                icon: const Icon(Icons.library_books_outlined),
                label: Text(tr.editor.previewPanel.scope.fullBook),
              ),
            ],
            selected: {scope},
            onSelectionChanged: (selection) {
              unawaited(onScopeChanged(selection.first));
            },
          ),
          OutlinedButton.icon(
            onPressed: onAssets,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Assets'),
          ),
          if (onOpenCurrentChapter != null)
            FilledButton.tonalIcon(
              onPressed: onOpenCurrentChapter,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                tr.editor.previewPanel.openCurrentChapter(
                  title: chapterTitle ?? tr.editor.previewPanel.scope.chapter,
                ),
              ),
            ),
          if (onRefresh != null)
            IconButton(
              tooltip: tr.editor.previewPanel.refreshFullBook,
              onPressed: loading ? null : onRefresh,
              icon: loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
            ),
        ],
      ),
    );
  }
}

final class _PdfPreview extends StatelessWidget {
  const _PdfPreview({
    required this.template,
    required this.settings,
    required this.markdown,
  });

  final BookTemplate template;
  final BookSettings settings;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final document = template.parse(markdown, settings: settings);
    return template.buildDocument(document);
  }
}

final class _EpubPreview extends StatelessWidget {
  const _EpubPreview({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  offset: Offset(0, 5),
                  color: Color(0x22000000),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tr.editor.previewPanel.epubReflowable,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 20),
                  MarkdownBlock(data: markdown),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
