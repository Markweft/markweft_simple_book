import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/markdown_command_toolbar.dart';
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
  static const SimpleBookTemplate _template = SimpleBookTemplate();
  static const XTypeGroup _pdfType = XTypeGroup(
    label: 'PDF document',
    extensions: <String>['pdf'],
  );

  late final TextEditingController _controller;
  Timer? _saveDebounce;
  String _markdown = '';
  String? _pendingMarkdown;
  String? _errorMessage;
  bool _saveInProgress = false;
  bool _pdfInProgress = false;
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;

  BookDocument get _document => _template.parse(_markdown);

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
      final markdown = await widget.projectRepository.loadMarkdown(
        widget.project,
      );
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
      final bytes = await _template.buildPdf(_document).save();
      await File(location.path).writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF exported to ${location.path}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to export PDF: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _pdfInProgress = false);
      }
    }
  }

  Future<void> _closeBook() async {
    _saveDebounce?.cancel();
    await _queueSave(_controller.text);
    if (!mounted || _saveStatus == SaveStatus.failed) return;
    await widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final pageCount = document.pages.length;

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
              '${_template.metadata.name} template '
              'v${_template.metadata.version} · ${widget.project.file.path}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Center(
            child: Text('$pageCount ${pageCount == 1 ? 'page' : 'pages'}'),
          ),
          const SizedBox(width: 12),
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
                        onChanged: _onMarkdownChanged,
                      );
                      final preview = _TemplatePreview(
                        template: _template,
                        document: document,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Markdown', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                const Tooltip(
                  message: 'Preview and PDF are rendered by '
                      'markweft_template_simple.',
                  child: Icon(Icons.extension_outlined, size: 19),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownCommandToolbar(
              controller: controller,
              onChanged: onChanged,
            ),
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

final class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({
    required this.template,
    required this.document,
  });

  final SimpleBookTemplate template;
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
                    '${template.metadata.name} · '
                    '${template.metadata.id} · '
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
