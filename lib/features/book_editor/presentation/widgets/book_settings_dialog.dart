import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/features/book_editor/application/template_registry.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookSettingsPage extends StatefulWidget {
  const BookSettingsPage({
    required this.settings,
    this.tocEntries = const <BookTocEntry>[],
    super.key,
  });

  final BookSettings settings;
  final List<BookTocEntry> tocEntries;

  @override
  State<BookSettingsPage> createState() => _BookSettingsPageState();
}

final class _BookSettingsPageState extends State<BookSettingsPage> {
  late BookSettings _settings;
  late String _selectedParagraphStyleId;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
    _selectedParagraphStyleId = _settings.defaultParagraphStyleId;
  }

  TemplateDescriptor get _descriptor =>
      TemplateRegistry.descriptor(_settings.templateId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book settings'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_settings),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 56),
            children: [
              _section(
                title: 'Document setup',
                icon: Icons.menu_book_outlined,
                children: _documentFields(),
              ),
              _section(
                title: 'Margins, bleed & facing pages',
                icon: Icons.crop_free_rounded,
                children: _layoutFields(),
              ),
              _section(
                title: 'Language & direction',
                icon: Icons.translate_rounded,
                children: _languageFields(),
              ),
              _section(
                title: 'Book metadata',
                icon: Icons.info_outline_rounded,
                children: _metadataFields(),
              ),
              _section(
                title: 'Header & footer',
                icon: Icons.view_stream_outlined,
                children: _runningContentFields(),
              ),
              _section(
                title: 'Cover',
                icon: Icons.auto_stories_outlined,
                children: _coverFields(),
              ),
              _section(
                title: 'Paragraph styles',
                icon: Icons.format_paragraph_rounded,
                children: _paragraphStyleFields(),
              ),
              _section(
                title: 'Table of contents',
                icon: Icons.toc_rounded,
                children: _tocFields(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 9),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _documentFields() {
    final metadata = _descriptor.template.metadata;
    return [
      _wrapFields([
        DropdownButtonFormField<String>(
          initialValue: _settings.templateId,
          decoration: const InputDecoration(labelText: 'Template'),
          items: [
            for (final item in TemplateRegistry.available)
              DropdownMenuItem(
                value: item.template.metadata.id,
                child: Text(
                  '${item.template.metadata.name} v${item.template.metadata.version}',
                ),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            final next = TemplateRegistry.descriptor(value);
            setState(() {
              _settings = _settings.copyWith(
                templateId: value,
                defaultColumns: next.supportedColumns.contains(
                  _settings.defaultColumns,
                )
                    ? _settings.defaultColumns
                    : next.supportedColumns.first,
              );
            });
          },
        ),
        DropdownButtonFormField<BookPageSize>(
          initialValue: _settings.pageSize,
          decoration: const InputDecoration(labelText: 'Page size'),
          items: [
            for (final value in BookPageSize.values)
              DropdownMenuItem(
                value: value,
                child: Text(value.name.toUpperCase()),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(pageSize: value));
          },
        ),
        DropdownButtonFormField<BookPageOrientation>(
          initialValue: _settings.orientation,
          decoration: const InputDecoration(labelText: 'Orientation'),
          items: const [
            DropdownMenuItem(
              value: BookPageOrientation.portrait,
              child: Text('Portrait'),
            ),
            DropdownMenuItem(
              value: BookPageOrientation.landscape,
              child: Text('Landscape'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(orientation: value));
          },
        ),
        DropdownButtonFormField<int>(
          initialValue: _settings.defaultColumns,
          decoration: const InputDecoration(labelText: 'Columns'),
          items: [
            for (final value in _descriptor.supportedColumns)
              DropdownMenuItem(value: value, child: Text('$value')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(defaultColumns: value));
          },
        ),
      ]),
      if (_settings.pageSize == BookPageSize.custom) ...[
        const SizedBox(height: 14),
        _wrapFields([
          _numberField(
            label: 'Custom width (mm)',
            value: _settings.customPageWidthMillimeters,
            min: 20,
            onChanged: (value) => setState(
              () => _settings = _settings.copyWith(
                customPageWidthMillimeters: value,
              ),
            ),
          ),
          _numberField(
            label: 'Custom height (mm)',
            value: _settings.customPageHeightMillimeters,
            min: 20,
            onChanged: (value) => setState(
              () => _settings = _settings.copyWith(
                customPageHeightMillimeters: value,
              ),
            ),
          ),
        ]),
      ],
      const SizedBox(height: 12),
      Text(
        'Template capabilities: ${metadata.supportedBookSettings.map((e) => e.name).join(', ')}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> _layoutFields() {
    final margins = _settings.effectivePageMargins;
    final bleed = _settings.bleed;
    return [
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Facing pages'),
        subtitle: const Text(
          'Uses inside/outside margins and previews the book as spreads.',
        ),
        value: _settings.facingPages,
        onChanged: (value) =>
            setState(() => _settings = _settings.copyWith(facingPages: value)),
      ),
      const SizedBox(height: 8),
      _wrapFields([
        _numberField(
          label: 'Top margin',
          value: margins.top,
          onChanged: (value) => _setMargins(margins.copyWith(top: value)),
        ),
        _numberField(
          label: 'Bottom margin',
          value: margins.bottom,
          onChanged: (value) => _setMargins(margins.copyWith(bottom: value)),
        ),
        _numberField(
          label: 'Inside margin',
          value: margins.inside,
          onChanged: (value) => _setMargins(margins.copyWith(inside: value)),
        ),
        _numberField(
          label: 'Outside margin',
          value: margins.outside,
          onChanged: (value) => _setMargins(margins.copyWith(outside: value)),
        ),
        _numberField(
          label: 'Content padding',
          value: _settings.contentPadding,
          onChanged: (value) => setState(
            () => _settings = _settings.copyWith(contentPadding: value),
          ),
        ),
      ]),
      const SizedBox(height: 18),
      Text('Bleed', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      _wrapFields([
        _numberField(
          label: 'Bleed top',
          value: bleed.top,
          onChanged: (value) => _setBleed(bleed.copyWith(top: value)),
        ),
        _numberField(
          label: 'Bleed right',
          value: bleed.right,
          onChanged: (value) => _setBleed(bleed.copyWith(right: value)),
        ),
        _numberField(
          label: 'Bleed bottom',
          value: bleed.bottom,
          onChanged: (value) => _setBleed(bleed.copyWith(bottom: value)),
        ),
        _numberField(
          label: 'Bleed left',
          value: bleed.left,
          onChanged: (value) => _setBleed(bleed.copyWith(left: value)),
        ),
      ]),
    ];
  }

  List<Widget> _languageFields() {
    return [
      _wrapFields([
        DropdownButtonFormField<String>(
          initialValue: _settings.languageCode,
          decoration: const InputDecoration(labelText: 'Book language'),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'ar', child: Text('Arabic')),
            DropdownMenuItem(value: 'fr', child: Text('French')),
            DropdownMenuItem(value: 'de', child: Text('German')),
            DropdownMenuItem(value: 'es', child: Text('Spanish')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(languageCode: value));
          },
        ),
        DropdownButtonFormField<BookDirection>(
          initialValue: _settings.direction,
          decoration: const InputDecoration(labelText: 'Text direction'),
          items: const [
            DropdownMenuItem(value: BookDirection.ltr, child: Text('LTR')),
            DropdownMenuItem(value: BookDirection.rtl, child: Text('RTL')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(direction: value));
          },
        ),
        DropdownButtonFormField<BookColorMode>(
          initialValue: _settings.colorMode,
          decoration: const InputDecoration(labelText: 'Page theme'),
          items: const [
            DropdownMenuItem(value: BookColorMode.light, child: Text('Light')),
            DropdownMenuItem(value: BookColorMode.dark, child: Text('Dark')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _settings = _settings.copyWith(colorMode: value));
          },
        ),
      ]),
      const SizedBox(height: 10),
      const Text(
        'RTL applies to the template preview, facing-page order, running content and PDF text direction. The Markdown editor also auto-detects Arabic RTL text.',
      ),
    ];
  }

  List<Widget> _metadataFields() {
    final metadata = _settings.metadata;
    return [
      _wrapFields([
        _textField(
          label: 'Title',
          value: metadata.title,
          onChanged: (value) => _setMetadata(metadata.copyWith(title: value)),
        ),
        _textField(
          label: 'Subtitle',
          value: metadata.subtitle,
          onChanged: (value) => _setMetadata(metadata.copyWith(subtitle: value)),
        ),
        _textField(
          label: 'Authors (comma separated)',
          value: metadata.authors.join(', '),
          onChanged: (value) => _setMetadata(
            metadata.copyWith(authors: _csv(value)),
          ),
        ),
        _textField(
          label: 'Publisher',
          value: metadata.publisher,
          onChanged: (value) => _setMetadata(metadata.copyWith(publisher: value)),
        ),
        _textField(
          label: 'ISBN',
          value: metadata.isbn,
          onChanged: (value) => _setMetadata(metadata.copyWith(isbn: value)),
        ),
        _textField(
          label: 'Edition',
          value: metadata.edition,
          onChanged: (value) => _setMetadata(metadata.copyWith(edition: value)),
        ),
        _textField(
          label: 'Published date',
          value: metadata.publishedDate,
          onChanged: (value) =>
              _setMetadata(metadata.copyWith(publishedDate: value)),
        ),
        _textField(
          label: 'Keywords (comma separated)',
          value: metadata.keywords.join(', '),
          onChanged: (value) => _setMetadata(
            metadata.copyWith(keywords: _csv(value)),
          ),
        ),
      ]),
      const SizedBox(height: 12),
      TextFormField(
        key: ValueKey('description-${metadata.description.hashCode}'),
        initialValue: metadata.description,
        minLines: 3,
        maxLines: 6,
        decoration: const InputDecoration(labelText: 'Description'),
        onChanged: (value) => _setMetadata(metadata.copyWith(description: value)),
      ),
      const SizedBox(height: 12),
      _textField(
        label: 'Copyright',
        value: metadata.copyright,
        onChanged: (value) => _setMetadata(metadata.copyWith(copyright: value)),
      ),
    ];
  }

  List<Widget> _runningContentFields() {
    final running = _settings.runningContent;
    return [
      _wrapFields([
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Header enabled'),
          value: running.headerEnabled,
          onChanged: (value) =>
              _setRunning(running.copyWith(headerEnabled: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Footer enabled'),
          value: running.footerEnabled,
          onChanged: (value) =>
              _setRunning(running.copyWith(footerEnabled: value)),
        ),
      ]),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Show on chapter-opening pages'),
        value: running.showOnChapterOpenings,
        onChanged: (value) =>
            _setRunning(running.copyWith(showOnChapterOpenings: value)),
      ),
      const SizedBox(height: 10),
      _wrapFields([
        _textField(
          label: 'Header · left page',
          value: running.headerLeftPage,
          onChanged: (value) =>
              _setRunning(running.copyWith(headerLeftPage: value)),
        ),
        _textField(
          label: 'Header · right page',
          value: running.headerRightPage,
          onChanged: (value) =>
              _setRunning(running.copyWith(headerRightPage: value)),
        ),
        _textField(
          label: 'Footer · left page',
          value: running.footerLeftPage,
          onChanged: (value) =>
              _setRunning(running.copyWith(footerLeftPage: value)),
        ),
        _textField(
          label: 'Footer · right page',
          value: running.footerRightPage,
          onChanged: (value) =>
              _setRunning(running.copyWith(footerRightPage: value)),
        ),
      ]),
      const SizedBox(height: 12),
      _wrapFields([
        _numberField(
          label: 'Header height',
          value: running.headerHeight,
          onChanged: (value) =>
              _setRunning(running.copyWith(headerHeight: value)),
        ),
        _numberField(
          label: 'Footer height',
          value: running.footerHeight,
          onChanged: (value) =>
              _setRunning(running.copyWith(footerHeight: value)),
        ),
        _numberField(
          label: 'Font size',
          value: running.fontSize,
          min: 5,
          onChanged: (value) =>
              _setRunning(running.copyWith(fontSize: value)),
        ),
      ]),
      const SizedBox(height: 10),
      const Text(
        'Tokens: {bookTitle}, {author}, {chapterTitle}, {pageNumber}, {pageCount}',
      ),
    ];
  }

  List<Widget> _coverFields() {
    final cover = _settings.cover;
    final styles = _descriptor.template.metadata.coverStyles;
    return [
      _wrapFields([
        DropdownButtonFormField<BookCoverMode>(
          initialValue: cover.mode,
          decoration: const InputDecoration(labelText: 'Cover mode'),
          items: [
            for (final value in BookCoverMode.values)
              DropdownMenuItem(value: value, child: Text(value.name)),
          ],
          onChanged: (value) {
            if (value == null) return;
            _setCover(cover.copyWith(mode: value));
          },
        ),
        DropdownButtonFormField<String>(
          initialValue: styles.any((style) => style.id == cover.styleId)
              ? cover.styleId
              : styles.firstOrNull?.id,
          decoration: const InputDecoration(labelText: 'Template cover style'),
          items: [
            for (final style in styles)
              DropdownMenuItem(value: style.id, child: Text(style.name)),
          ],
          onChanged: (value) {
            if (value == null) return;
            _setCover(cover.copyWith(styleId: value));
          },
        ),
      ]),
      const SizedBox(height: 12),
      _wrapFields([
        _textField(
          label: 'Cover title override',
          value: cover.titleOverride,
          onChanged: (value) => _setCover(cover.copyWith(titleOverride: value)),
        ),
        _textField(
          label: 'Cover subtitle override',
          value: cover.subtitleOverride,
          onChanged: (value) =>
              _setCover(cover.copyWith(subtitleOverride: value)),
        ),
        _textField(
          label: 'Cover author override',
          value: cover.authorOverride,
          onChanged: (value) =>
              _setCover(cover.copyWith(authorOverride: value)),
        ),
        _numberField(
          label: 'Image overlay 0–1',
          value: cover.overlayOpacity,
          min: 0,
          max: 1,
          onChanged: (value) =>
              _setCover(cover.copyWith(overlayOpacity: value)),
        ),
      ]),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: _pickCoverImage,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              cover.imageDataUri == null ? 'Choose cover image' : 'Replace image',
            ),
          ),
          if (cover.imageDataUri != null)
            TextButton.icon(
              onPressed: () => _setCover(cover.copyWith(clearImage: true)),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove image'),
            ),
        ],
      ),
    ];
  }

  List<Widget> _paragraphStyleFields() {
    if (_settings.paragraphStyles.isEmpty) return const <Widget>[];
    final selected = _settings.paragraphStyles.firstWhere(
      (style) => style.id == _selectedParagraphStyleId,
      orElse: () => _settings.paragraphStyles.first,
    );

    return [
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 280,
            child: DropdownButtonFormField<String>(
              key: ValueKey('style-$_selectedParagraphStyleId'),
              initialValue: selected.id,
              decoration: const InputDecoration(labelText: 'Style'),
              items: [
                for (final style in _settings.paragraphStyles)
                  DropdownMenuItem(value: style.id, child: Text(style.name)),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedParagraphStyleId = value);
              },
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: _addParagraphStyle,
            icon: const Icon(Icons.add),
            label: const Text('New style'),
          ),
          OutlinedButton.icon(
            onPressed: selected.id == _settings.defaultParagraphStyleId
                ? null
                : () => setState(
                      () => _settings = _settings.copyWith(
                        defaultParagraphStyleId: selected.id,
                      ),
                    ),
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              selected.id == _settings.defaultParagraphStyleId
                  ? 'Default style'
                  : 'Set as default',
            ),
          ),
          TextButton.icon(
            onPressed: _settings.paragraphStyles.length <= 1
                ? null
                : () => _deleteParagraphStyle(selected.id),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _wrapFields([
        _textField(
          label: 'Style name',
          value: selected.name,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(name: value)),
        ),
        _textField(
          label: 'Font family',
          value: selected.fontFamily ?? '',
          onChanged: (value) => _updateParagraphStyle(
            selected.copyWith(
              fontFamily: value.trim().isEmpty ? null : value,
              clearFontFamily: value.trim().isEmpty,
            ),
          ),
        ),
        _numberField(
          label: 'Font size',
          value: selected.fontSize,
          min: 5,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(fontSize: value)),
        ),
        DropdownButtonFormField<int>(
          initialValue: selected.fontWeight,
          decoration: const InputDecoration(labelText: 'Font weight'),
          items: [
            for (final weight in const [100, 200, 300, 400, 500, 600, 700, 800, 900])
              DropdownMenuItem(value: weight, child: Text('$weight')),
          ],
          onChanged: (value) {
            if (value == null) return;
            _updateParagraphStyle(selected.copyWith(fontWeight: value));
          },
        ),
        _numberField(
          label: 'Line height',
          value: selected.lineHeight,
          min: 0.8,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(lineHeight: value)),
        ),
        DropdownButtonFormField<BookTextAlignment>(
          initialValue: selected.alignment,
          decoration: const InputDecoration(labelText: 'Alignment'),
          items: [
            for (final value in BookTextAlignment.values)
              DropdownMenuItem(value: value, child: Text(value.name)),
          ],
          onChanged: (value) {
            if (value == null) return;
            _updateParagraphStyle(selected.copyWith(alignment: value));
          },
        ),
        _numberField(
          label: 'First-line indent',
          value: selected.firstLineIndent,
          onChanged: (value) => _updateParagraphStyle(
            selected.copyWith(firstLineIndent: value),
          ),
        ),
        _numberField(
          label: 'Space before',
          value: selected.spaceBefore,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(spaceBefore: value)),
        ),
        _numberField(
          label: 'Space after',
          value: selected.spaceAfter,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(spaceAfter: value)),
        ),
        _numberField(
          label: 'Start indent',
          value: selected.startIndent,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(startIndent: value)),
        ),
        _numberField(
          label: 'End indent',
          value: selected.endIndent,
          onChanged: (value) =>
              _updateParagraphStyle(selected.copyWith(endIndent: value)),
        ),
      ]),
      const SizedBox(height: 12),
      Text(
        'Apply a style in Markdown with: [style:${selected.id}] Your paragraph text',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> _tocFields() {
    final toc = _settings.tableOfContents;
    return [
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: const Text('Generate table of contents'),
        subtitle: Text('${widget.tocEntries.length} detected heading entries'),
        value: toc.enabled,
        onChanged: (value) => setState(
          () => _settings = _settings.copyWith(
            tableOfContents: toc.copyWith(enabled: value),
          ),
        ),
      ),
      _wrapFields([
        _textField(
          label: 'TOC title',
          value: toc.title,
          onChanged: (value) => setState(
            () => _settings = _settings.copyWith(
              tableOfContents: toc.copyWith(title: value),
            ),
          ),
        ),
        DropdownButtonFormField<int>(
          initialValue: toc.maxDepth,
          decoration: const InputDecoration(labelText: 'Heading depth'),
          items: [
            for (var depth = 1; depth <= 6; depth++)
              DropdownMenuItem(value: depth, child: Text('$depth')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(
              () => _settings = _settings.copyWith(
                tableOfContents: toc.copyWith(maxDepth: value),
              ),
            );
          },
        ),
      ]),
    ];
  }

  Widget _wrapFields(List<Widget> fields) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 760
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth >= 500
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in fields)
              SizedBox(width: width, child: field),
          ],
        );
      },
    );
  }

  Widget _textField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      key: ValueKey('$label-${value.hashCode}'),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _numberField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0,
    double? max,
  }) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: _formatNumber(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      onChanged: (raw) {
        final parsed = double.tryParse(raw);
        if (parsed == null || parsed < min || (max != null && parsed > max)) {
          return;
        }
        onChanged(parsed);
      },
    );
  }

  void _setMargins(BookPageMargins value) {
    setState(() => _settings = _settings.copyWith(pageMargins: value));
  }

  void _setBleed(BookBleed value) {
    setState(() => _settings = _settings.copyWith(bleed: value));
  }

  void _setMetadata(BookMetadata value) {
    setState(() => _settings = _settings.copyWith(metadata: value));
  }

  void _setRunning(RunningContentSettings value) {
    setState(() => _settings = _settings.copyWith(runningContent: value));
  }

  void _setCover(BookCoverSettings value) {
    setState(() => _settings = _settings.copyWith(cover: value));
  }

  Future<void> _pickCoverImage() async {
    const types = XTypeGroup(
      label: 'Cover image',
      extensions: <String>['png', 'jpg', 'jpeg'],
    );
    final file = await openFile(acceptedTypeGroups: const <XTypeGroup>[types]);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final lower = file.path.toLowerCase();
    final mime = lower.endsWith('.png') ? 'image/png' : 'image/jpeg';
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    if (!mounted) return;
    _setCover(_settings.cover.copyWith(imageDataUri: dataUri));
  }

  void _updateParagraphStyle(ParagraphStyleDefinition updated) {
    final styles = <ParagraphStyleDefinition>[
      for (final style in _settings.paragraphStyles)
        if (style.id == updated.id) updated else style,
    ];
    setState(() => _settings = _settings.copyWith(paragraphStyles: styles));
  }

  void _addParagraphStyle() {
    var number = _settings.paragraphStyles.length + 1;
    var id = 'style-$number';
    final ids = _settings.paragraphStyles.map((style) => style.id).toSet();
    while (ids.contains(id)) {
      number++;
      id = 'style-$number';
    }
    final style = ParagraphStyleDefinition(
      id: id,
      name: 'Style $number',
      fontFamily: _settings.typography.fontFamily,
      fontSize: _settings.typography.fontSize,
      fontWeight: _settings.typography.fontWeight,
      lineHeight: _settings.typography.lineHeight,
      alignment: _settings.typography.alignment,
    );
    setState(() {
      _settings = _settings.copyWith(
        paragraphStyles: <ParagraphStyleDefinition>[
          ..._settings.paragraphStyles,
          style,
        ],
      );
      _selectedParagraphStyleId = id;
    });
  }

  void _deleteParagraphStyle(String id) {
    final styles = _settings.paragraphStyles
        .where((style) => style.id != id)
        .toList(growable: false);
    if (styles.isEmpty) return;
    final defaultId = _settings.defaultParagraphStyleId == id
        ? styles.first.id
        : _settings.defaultParagraphStyleId;
    setState(() {
      _settings = _settings.copyWith(
        paragraphStyles: styles,
        defaultParagraphStyleId: defaultId,
      );
      _selectedParagraphStyleId = styles.first.id;
    });
  }

  List<String> _csv(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble() ? '${value.toInt()}' : '$value';
  }
}
