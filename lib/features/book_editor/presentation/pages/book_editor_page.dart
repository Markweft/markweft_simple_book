import 'dart:async';

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_document_parser.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_table_paginator.dart';
import 'package:markweft_simple_book/features/book_editor/domain/entities/book_page.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/markdown_command_toolbar.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';

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
  static const BookDocumentParser _parser = BookDocumentParser();
  static const BookTablePaginator _tablePaginator = BookTablePaginator();

  late final TextEditingController _controller;
  Timer? _saveDebounce;
  String _markdown = '';
  String? _pendingMarkdown;
  String? _errorMessage;
  bool _saveInProgress = false;
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;
  BookPageSettings _defaults = const BookPageSettings();

  List<BookPageDocument> get _pages {
    final logicalPages = _parser.parse(
      _markdown,
      defaults: _defaults,
    );
    return _tablePaginator.paginate(logicalPages);
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    unawaited(_loadBook());
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      final markdown =
          await widget.projectRepository.loadMarkdown(widget.project);
      if (!mounted) return;

      _controller.text = markdown;
      setState(() {
        _markdown = markdown;
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

  void _onMarkdownChanged(String value) {
    setState(() {
      _markdown = value;
      _saveStatus = SaveStatus.saving;
      _errorMessage = null;
    });

    _saveDebounce?.cancel();
    _saveDebounce = Timer(
      const Duration(milliseconds: 650),
      () => unawaited(_queueSave(value)),
    );
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
        final value = _pendingMarkdown!;
        _pendingMarkdown = null;
        await widget.projectRepository.saveMarkdown(widget.project, value);
      }

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
          _errorMessage = 'Unable to save the .mdw project: $error';
        });
      }
    } finally {
      _saveInProgress = false;
      _saveCompleter?.complete();
      _saveCompleter = null;
    }
  }

  Future<void> _saveNow() async {
    _saveDebounce?.cancel();
    setState(() => _saveStatus = SaveStatus.saving);
    await _queueSave(_controller.text);
  }

  Future<void> _closeBook() async {
    _saveDebounce?.cancel();
    await _queueSave(_controller.text);
    if (!mounted || _saveStatus == SaveStatus.failed) return;
    await widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;

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
              widget.project.file.path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Center(
            child: Text(
              '${pages.length} ${pages.length == 1 ? 'page' : 'pages'}',
            ),
          ),
          const SizedBox(width: 16),
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
                        onChanged: _onMarkdownChanged,
                      );
                      final preview = _BookPreview(
                        pages: pages,
                        defaults: _defaults,
                        onDefaultsChanged: (value) {
                          setState(() => _defaults = value);
                        },
                      );

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

final class _SaveStatusView extends StatelessWidget {
  const _SaveStatusView({required this.status, required this.path});

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

final class _MarkdownEditor extends StatelessWidget {
  const _MarkdownEditor({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Markdown', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                const Tooltip(
                  message: 'Use the toolbar to insert Markdown commands.',
                  child: Icon(Icons.help_outline, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownCommandToolbar(
              controller: controller,
              onChanged: onChanged,
            ),
            const SizedBox(height: 8),
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
                  hintText: 'Write Markdown here...',
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

final class _BookPreview extends StatelessWidget {
  const _BookPreview({
    required this.pages,
    required this.defaults,
    required this.onDefaultsChanged,
  });

  final List<BookPageDocument> pages;
  final BookPageSettings defaults;
  final ValueChanged<BookPageSettings> onDefaultsChanged;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE8E3DB),
      child: Column(
        children: [
          _PreviewControls(
            defaults: defaults,
            pageCount: pages.length,
            onChanged: onDefaultsChanged,
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(32),
              itemCount: pages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 32),
              itemBuilder: (context, index) {
                return _BookPageCard(
                  page: pages[index],
                  pageNumber: index + 1,
                  pageCount: pages.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _PreviewControls extends StatelessWidget {
  const _PreviewControls({
    required this.defaults,
    required this.pageCount,
    required this.onChanged,
  });

  final BookPageSettings defaults;
  final int pageCount;
  final ValueChanged<BookPageSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text('$pageCount ${pageCount == 1 ? 'page' : 'pages'}'),
          const SizedBox(width: 20),
          DropdownButton<BookPageSize>(
            value: defaults.size,
            onChanged: (value) {
              if (value != null) onChanged(defaults.copyWith(size: value));
            },
            items: BookPageSize.values
                .map(
                  (size) => DropdownMenuItem(
                    value: size,
                    child: Text(size.name.toUpperCase()),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(width: 12),
          DropdownButton<BookPageOrientation>(
            value: defaults.orientation,
            onChanged: (value) {
              if (value != null) {
                onChanged(defaults.copyWith(orientation: value));
              }
            },
            items: BookPageOrientation.values
                .map(
                  (orientation) => DropdownMenuItem(
                    value: orientation,
                    child: Text(orientation.name),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(width: 20),
          Text('Margin ${defaults.margin.round()}'),
          SizedBox(
            width: 130,
            child: Slider(
              value: defaults.margin,
              min: 0,
              max: 80,
              divisions: 20,
              onChanged: (value) {
                onChanged(defaults.copyWith(margin: value));
              },
            ),
          ),
          Text('Padding ${defaults.padding.round()}'),
          SizedBox(
            width: 130,
            child: Slider(
              value: defaults.padding,
              min: 8,
              max: 100,
              divisions: 23,
              onChanged: (value) {
                onChanged(defaults.copyWith(padding: value));
              },
            ),
          ),
        ],
      ),
    );
  }
}

final class _BookPageCard extends StatelessWidget {
  const _BookPageCard({
    required this.page,
    required this.pageNumber,
    required this.pageCount,
  });

  final BookPageDocument page;
  final int pageNumber;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    final settings = page.settings;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(settings.margin),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: AspectRatio(
            aspectRatio: settings.aspectRatio,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    color: Color(0x33000000),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        settings.padding,
                        settings.padding,
                        settings.padding,
                        settings.padding + 24,
                      ),
                      child: _PageLayout(
                        layout: settings.layout,
                        markdown: page.markdown,
                        template: settings.template,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 10,
                    child: Text(
                      '$pageNumber / $pageCount',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    child: Text(
                      '${settings.size.name.toUpperCase()} · '
                      '${settings.orientation.name} · ${settings.layout}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _PageLayout extends StatelessWidget {
  const _PageLayout({
    required this.layout,
    required this.markdown,
    required this.template,
  });

  final String layout;
  final String markdown;
  final Map<String, Object?> template;

  @override
  Widget build(BuildContext context) {
    if (layout.toLowerCase() == 'test') {
      final title = template['title']?.toString();
      final description = template['description']?.toString();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title.isNotEmpty)
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description),
            const Divider(height: 28),
          ],
          Expanded(child: _MarkdownPage(markdown: markdown)),
        ],
      );
    }

    return _MarkdownPage(markdown: markdown);
  }
}

final class _MarkdownPage extends StatelessWidget {
  const _MarkdownPage({required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: MarkdownWidget(
                data: markdown,
                shrinkWrap: true,
                config: MarkdownConfig(
                  configs: [
                    const H1Config(
                      style: TextStyle(
                        color: Color(0xFF2B2520),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const H2Config(
                      style: TextStyle(
                        color: Color(0xFF4A4036),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const PConfig(
                      textStyle: TextStyle(
                        color: Color(0xFF302C28),
                        fontSize: 16,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
