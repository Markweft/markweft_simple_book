import 'dart:async';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/features/book_editor/application/template_registry.dart';
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
  bool _settingsInProgress = false;
  Completer<void>? _saveCompleter;
  SaveStatus _saveStatus = SaveStatus.loading;
  BookSettings _bookSettings = const BookSettings();

  BookTemplate get _template => TemplateRegistry.resolve(
        _bookSettings.templateId,
      );

  BookDocument get _document => _template.parse(
        _markdown,
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    try {
      final markdown = await widget.projectRepository.loadMarkdown(
        widget.project,
      );
      final settings = await widget.projectRepository.loadBookSettings(
        widget.project,
      );
      if (!mounted) return;

      _controller.text = markdown;
      setState(() {
        _markdown = markdown;
        _bookSettings = settings;
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

  Future<void> _showBookSettings() async {
    final settings = await showDialog<BookSettings>(
      context: context,
      builder: (_) => _BookSettingsDialog(settings: _bookSettings),
    );
    if (settings == null || !mounted) return;

    setState(() {
      _bookSettings = settings;
      _settingsInProgress = true;
      _errorMessage = null;
    });

    try {
      await widget.projectRepository.saveBookSettings(
        widget.project,
        settings,
      );
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to save book settings: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _settingsInProgress = false);
      }
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

    final safeTitle = title.replaceAll('-->', '—').trim();
    final prefix = _controller.text.trimRight();
    final separator = prefix.isEmpty ? '' : '\n\n';
    final addition = '$separator<!-- chapter: $safeTitle -->\n\n# $safeTitle\n\n';
    final value = '$prefix$addition';

    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _onMarkdownChanged(value);
  }

  void _jumpToChapter(int chapterIndex) {
    final matches = RegExp(
      r'^\s*<!--\s*chapter\s*:\s*.*?\s*-->\s*$',
      caseSensitive: false,
      multiLine: true,
    ).allMatches(_controller.text).toList();
    if (chapterIndex < 0 || chapterIndex >= matches.length) return;

    final offset = matches[chapterIndex].start;
    _controller.selection = TextSelection.collapsed(offset: offset);
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
                        onChanged: _onMarkdownChanged,
                      );
                      final preview = _TemplatePreview(
                        template: _template,
                        document: document,
                      );
                      final chapters = _ChapterSidebar(
                        chapters: document.chapters,
                        onAddChapter: _addChapter,
                        onSelectChapter: _jumpToChapter,
                      );

                      if (constraints.maxWidth >= 1200) {
                        return Row(
                          children: [
                            SizedBox(width: 240, child: chapters),
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
                  message: 'Preview and PDF are rendered by the selected template.',
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

final class _ChapterSidebar extends StatelessWidget {
  const _ChapterSidebar({
    required this.chapters,
    required this.onAddChapter,
    required this.onSelectChapter,
  });

  final List<BookChapter> chapters;
  final VoidCallback onAddChapter;
  final ValueChanged<int> onSelectChapter;

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
            child: chapters.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No chapter markers yet. Add a chapter to create a '
                      '<!-- chapter: Title --> section.',
                    ),
                  )
                : ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          chapter.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${chapter.pageCount} '
                          '${chapter.pageCount == 1 ? 'page' : 'pages'}',
                        ),
                        onTap: () => onSelectChapter(index),
                      );
                    },
                  ),
          ),
        ],
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

final class _BookSettingsDialog extends StatefulWidget {
  const _BookSettingsDialog({required this.settings});

  final BookSettings settings;

  @override
  State<_BookSettingsDialog> createState() => _BookSettingsDialogState();
}

final class _BookSettingsDialogState extends State<_BookSettingsDialog> {
  late BookSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = TemplateRegistry.descriptor(_settings.templateId);
    final typography = _settings.typography;

    return AlertDialog(
      title: const Text('Book settings'),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Document', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _settings.templateId,
                decoration: const InputDecoration(labelText: 'Template'),
                items: [
                  for (final item in TemplateRegistry.available)
                    DropdownMenuItem(
                      value: item.template.metadata.id,
                      child: Text(item.template.metadata.name),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  final nextDescriptor = TemplateRegistry.descriptor(value);
                  final columns = nextDescriptor.supportedColumns.contains(
                    _settings.defaultColumns,
                  )
                      ? _settings.defaultColumns
                      : nextDescriptor.supportedColumns.first;
                  setState(() {
                    _settings = _settings.copyWith(
                      templateId: value,
                      defaultColumns: columns,
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<BookPageSize>(
                      initialValue: _settings.pageSize,
                      decoration: const InputDecoration(labelText: 'Page size'),
                      items: [
                        for (final size in BookPageSize.values)
                          DropdownMenuItem(
                            value: size,
                            child: Text(size.name.toUpperCase()),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _settings = _settings.copyWith(pageSize: value));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<BookPageOrientation>(
                      initialValue: _settings.orientation,
                      decoration: const InputDecoration(labelText: 'Orientation'),
                      items: [
                        for (final orientation in BookPageOrientation.values)
                          DropdownMenuItem(
                            value: orientation,
                            child: Text(orientation.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _settings = _settings.copyWith(orientation: value),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: _settings.margin,
                      decoration: const InputDecoration(labelText: 'Margin'),
                      items: const [12, 24, 36, 48, 60]
                          .map(
                            (value) => DropdownMenuItem<double>(
                              value: value.toDouble(),
                              child: Text('$value pt'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _settings = _settings.copyWith(margin: value));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: _settings.contentPadding,
                      decoration: const InputDecoration(labelText: 'Content padding'),
                      items: const [0, 12, 24, 36, 48]
                          .map(
                            (value) => DropdownMenuItem<double>(
                              value: value.toDouble(),
                              child: Text('$value pt'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _settings = _settings.copyWith(contentPadding: value),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _settings.defaultColumns,
                decoration: const InputDecoration(labelText: 'Default columns'),
                items: [
                  for (final columns in descriptor.supportedColumns)
                    DropdownMenuItem(
                      value: columns,
                      child: Text('$columns'),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(
                    () => _settings = _settings.copyWith(defaultColumns: value),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Language', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _settings.languageCode,
                      decoration: const InputDecoration(labelText: 'Book language'),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                        DropdownMenuItem(value: 'fr', child: Text('French')),
                        DropdownMenuItem(value: 'de', child: Text('German')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        final defaultDirection = value == 'ar'
                            ? BookDirection.rtl
                            : BookDirection.ltr;
                        setState(
                          () => _settings = _settings.copyWith(
                            languageCode: value,
                            direction: defaultDirection,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<BookDirection>(
                      initialValue: _settings.direction,
                      decoration: const InputDecoration(labelText: 'Direction'),
                      items: const [
                        DropdownMenuItem(
                          value: BookDirection.ltr,
                          child: Text('LTR'),
                        ),
                        DropdownMenuItem(
                          value: BookDirection.rtl,
                          child: Text('RTL'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _settings = _settings.copyWith(direction: value),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Typography', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: typography.fontFamily ?? 'system',
                decoration: const InputDecoration(labelText: 'Font family'),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System default')),
                  DropdownMenuItem(value: 'serif', child: Text('Serif')),
                  DropdownMenuItem(value: 'sans-serif', child: Text('Sans serif')),
                  DropdownMenuItem(value: 'monospace', child: Text('Monospace')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _settings = _settings.copyWith(
                      typography: typography.copyWith(
                        fontFamily: value == 'system' ? null : value,
                        clearFontFamily: value == 'system',
                      ),
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: typography.fontSize,
                      decoration: const InputDecoration(labelText: 'Font size'),
                      items: const [10, 11, 12, 14, 16, 18, 20]
                          .map(
                            (value) => DropdownMenuItem<double>(
                              value: value.toDouble(),
                              child: Text('$value pt'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            typography: typography.copyWith(fontSize: value),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: typography.fontWeight,
                      decoration: const InputDecoration(labelText: 'Weight'),
                      items: const [300, 400, 500, 600, 700]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            typography: typography.copyWith(fontWeight: value),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: typography.lineHeight,
                      decoration: const InputDecoration(labelText: 'Line height'),
                      items: const [1.2, 1.4, 1.5, 1.6, 1.8, 2.0]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            typography: typography.copyWith(lineHeight: value),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<BookTextAlignment>(
                      initialValue: typography.alignment,
                      decoration: const InputDecoration(labelText: 'Alignment'),
                      items: [
                        for (final alignment in BookTextAlignment.values)
                          DropdownMenuItem(
                            value: alignment,
                            child: Text(alignment.name),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            typography: typography.copyWith(alignment: value),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Chapter opening pages use the template-specific '
                '${descriptor.chapterLayouts.first} layout by default.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_settings),
          child: const Text('Save'),
        ),
      ],
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
