import 'dart:async';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_output_format.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_simple_book/i18n/strings.g.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

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
  late BookOutputFormat _format;
  late BookPreviewScope _scope;
  String? _wholeBookMarkdown;
  bool _loadingWholeBook = false;
  Object? _wholeBookError;

  @override
  void initState() {
    super.initState();
    _format = widget.initialFormat;
    _scope = widget.initialScope;
    if (_scope == BookPreviewScope.book) {
      unawaited(_loadWholeBook());
    }
  }

  @override
  void didUpdateWidget(covariant BookPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.file.path != widget.project.file.path) {
      _wholeBookMarkdown = null;
      _wholeBookError = null;
      if (_scope == BookPreviewScope.book) {
        unawaited(_loadWholeBook());
      }
    }
  }

  Future<void> _setScope(BookPreviewScope scope) async {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    if (scope == BookPreviewScope.book) {
      await _loadWholeBook();
    }
  }

  Future<void> _loadWholeBook() async {
    if (_loadingWholeBook) return;
    setState(() {
      _loadingWholeBook = true;
      _wholeBookError = null;
    });

    try {
      await widget.onBeforeFullBookPreview();
      final markdown = await widget.projectRepository.loadWholeBookMarkdown(
        widget.project,
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
            format: _format,
            scope: _scope,
            loading: _loadingWholeBook,
            onFormatChanged: (value) => setState(() => _format = value),
            onScopeChanged: _setScope,
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
              Text(tr.editor.fullBookLoadFailed),
              const SizedBox(height: 8),
              Text('$_wholeBookError', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadWholeBook,
                icon: const Icon(Icons.refresh),
                label: Text(tr.app.retry),
              ),
            ],
          ),
        ),
      );
    }

    final source = markdown ?? '';
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
    required this.format,
    required this.scope,
    required this.loading,
    required this.onFormatChanged,
    required this.onScopeChanged,
    required this.onRefresh,
  });

  final BookOutputFormat format;
  final BookPreviewScope scope;
  final bool loading;
  final ValueChanged<BookOutputFormat> onFormatChanged;
  final Future<void> Function(BookPreviewScope) onScopeChanged;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SegmentedButton<BookOutputFormat>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: BookOutputFormat.pdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(tr.editor.pdf),
              ),
              ButtonSegment(
                value: BookOutputFormat.epub,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(tr.editor.epub),
              ),
            ],
            selected: {format},
            onSelectionChanged: (selection) => onFormatChanged(selection.first),
          ),
          SegmentedButton<BookPreviewScope>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: BookPreviewScope.chapter,
                icon: const Icon(Icons.article_outlined),
                label: Text(tr.editor.chapter),
              ),
              ButtonSegment(
                value: BookPreviewScope.book,
                icon: const Icon(Icons.library_books_outlined),
                label: Text(tr.editor.fullBook),
              ),
            ],
            selected: {scope},
            onSelectionChanged: (selection) {
              unawaited(onScopeChanged(selection.first));
            },
          ),
          if (onRefresh != null)
            IconButton(
              tooltip: tr.editor.refreshFullBook,
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
                    tr.editor.epubReflowablePreview,
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
