import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
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

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final descriptor = TemplateRegistry.descriptor(_settings.templateId);
    final document = tr.bookSettings.sections.document;
    final appearance = tr.bookSettings.sections.appearance;
    final language = tr.bookSettings.sections.language;
    final typography = tr.bookSettings.sections.typography;
    final toc = tr.bookSettings.sections.toc;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.bookSettings.page.title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_settings),
              icon: const Icon(Icons.check_rounded),
              label: Text(tr.app.actions.save),
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
            children: [
              _SettingsSection(
                title: document.title,
                icon: Icons.description_outlined,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _settings.templateId,
                    decoration: InputDecoration(labelText: document.template),
                    items: [
                      for (final item in TemplateRegistry.available)
                        DropdownMenuItem(
                          value: item.template.metadata.id,
                          child: Text(
                            '${item.template.metadata.name} '
                            'v${item.template.metadata.version}',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      final next = TemplateRegistry.descriptor(value);
                      setState(() {
                        _settings = _settings.copyWith(
                          templateId: value,
                          defaultColumns:
                              next.supportedColumns.contains(_settings.defaultColumns)
                                  ? _settings.defaultColumns
                                  : next.supportedColumns.first,
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Text('${document.platforms}:'),
                      if (descriptor.supportsPdf)
                        Chip(
                          avatar: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                          label: Text(document.pdf),
                        ),
                      if (descriptor.supportsEpub)
                        Chip(
                          avatar: const Icon(Icons.menu_book_outlined, size: 16),
                          label: Text(document.epub),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _TwoColumns(
                    first: DropdownButtonFormField<BookPageSize>(
                      initialValue: _settings.pageSize,
                      decoration: InputDecoration(labelText: document.pageSize),
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
                    second: DropdownButtonFormField<BookPageOrientation>(
                      initialValue: _settings.orientation,
                      decoration: InputDecoration(labelText: document.orientation),
                      items: [
                        DropdownMenuItem(
                          value: BookPageOrientation.portrait,
                          child: Text(document.orientationValues.portrait),
                        ),
                        DropdownMenuItem(
                          value: BookPageOrientation.landscape,
                          child: Text(document.orientationValues.landscape),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _settings = _settings.copyWith(orientation: value));
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TwoColumns(
                    first: _DoubleDropdown(
                      label: document.pageMargin,
                      value: _settings.margin,
                      values: const [12, 18, 24, 30, 36, 48, 60],
                      onChanged: (value) => setState(
                        () => _settings = _settings.copyWith(margin: value),
                      ),
                    ),
                    second: _DoubleDropdown(
                      label: document.contentPadding,
                      value: _settings.contentPadding,
                      values: const [0, 8, 12, 18, 24, 36, 48],
                      onChanged: (value) => setState(
                        () => _settings = _settings.copyWith(contentPadding: value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _settings.defaultColumns,
                    decoration: InputDecoration(
                      labelText: document.columns.title,
                      helperText: document.columns.helper,
                    ),
                    items: [
                      for (final value in descriptor.supportedColumns)
                        DropdownMenuItem(value: value, child: Text('$value')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _settings = _settings.copyWith(defaultColumns: value));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: appearance.title,
                icon: Icons.contrast_rounded,
                children: [
                  DropdownButtonFormField<BookColorMode>(
                    initialValue: _settings.colorMode,
                    decoration: InputDecoration(
                      labelText: appearance.colorMode,
                      helperText: appearance.description,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: BookColorMode.light,
                        child: Text(appearance.light),
                      ),
                      DropdownMenuItem(
                        value: BookColorMode.dark,
                        child: Text(appearance.dark),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _settings = _settings.copyWith(colorMode: value));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: language.title,
                icon: Icons.language_outlined,
                children: [
                  _TwoColumns(
                    first: DropdownButtonFormField<String>(
                      initialValue: _settings.languageCode,
                      decoration: InputDecoration(labelText: language.bookLanguage),
                      items: [
                        DropdownMenuItem(value: 'en', child: Text(tr.language.locales.en)),
                        DropdownMenuItem(value: 'ar', child: Text(tr.language.locales.ar)),
                        DropdownMenuItem(value: 'fr', child: Text(tr.language.locales.fr)),
                        DropdownMenuItem(value: 'de', child: Text(tr.language.locales.de)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            languageCode: value,
                            direction: value == 'ar'
                                ? BookDirection.rtl
                                : BookDirection.ltr,
                          );
                        });
                      },
                    ),
                    second: DropdownButtonFormField<BookDirection>(
                      initialValue: _settings.direction,
                      decoration: InputDecoration(labelText: language.direction),
                      items: [
                        DropdownMenuItem(
                          value: BookDirection.ltr,
                          child: Text(language.directionValues.ltr),
                        ),
                        DropdownMenuItem(
                          value: BookDirection.rtl,
                          child: Text(language.directionValues.rtl),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _settings = _settings.copyWith(direction: value));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _TypographySection(
                settings: _settings,
                labels: typography,
                onChanged: (value) => setState(() => _settings = value),
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: toc.title,
                icon: Icons.toc_rounded,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _settings.tableOfContents.enabled,
                    title: Text(toc.enabled),
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(
                          tableOfContents:
                              _settings.tableOfContents.copyWith(enabled: value),
                        );
                      });
                    },
                  ),
                  if (_settings.tableOfContents.enabled) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _settings.tableOfContents.title,
                      decoration: InputDecoration(labelText: toc.pageTitle),
                      onChanged: (value) {
                        _settings = _settings.copyWith(
                          tableOfContents:
                              _settings.tableOfContents.copyWith(title: value),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _settings.tableOfContents.maxDepth,
                      decoration: InputDecoration(labelText: toc.maxDepth),
                      items: [
                        for (var depth = 1; depth <= 6; depth++)
                          DropdownMenuItem(value: depth, child: Text('$depth')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _settings = _settings.copyWith(
                            tableOfContents:
                                _settings.tableOfContents.copyWith(maxDepth: value),
                          );
                        });
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _settings.tableOfContents.startOnNewPage,
                      title: Text(toc.startOnNewPage),
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            tableOfContents: _settings.tableOfContents
                                .copyWith(startOnNewPage: value),
                          );
                        });
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _settings.tableOfContents.includePageNumbers,
                      title: Text(toc.pageNumbers),
                      subtitle: Text(toc.pageNumbersHint),
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(
                            tableOfContents: _settings.tableOfContents
                                .copyWith(includePageNumbers: value),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _previewToc,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(toc.preview),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              _SettingsSection(
                title: tr.bookSettings.sections.templateBehavior.title,
                icon: Icons.auto_awesome_outlined,
                children: [
                  Text(
                    tr.bookSettings.sections.templateBehavior.chapterOpeningLayout(
                      layout: descriptor.chapterLayouts.first,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _previewToc() async {
    final template = TemplateRegistry.resolve(_settings.templateId);
    final entries = widget.tocEntries.isEmpty
        ? const <BookTocEntry>[
            BookTocEntry(title: 'Chapter One', level: 1),
            BookTocEntry(title: 'Section 1.1', level: 2),
            BookTocEntry(title: 'Chapter Two', level: 1),
          ]
        : widget.tocEntries;
    final markdown = template.buildTableOfContentsMarkdown(
      entries: entries,
      settings: _settings.tableOfContents,
    );
    final document = template.parse(markdown, settings: _settings);

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(Translations.of(context).bookSettings.sections.toc.preview),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: template.buildDocument(document),
        ),
      ),
    );
  }
}

final class _TypographySection extends StatelessWidget {
  const _TypographySection({
    required this.settings,
    required this.labels,
    required this.onChanged,
  });

  final BookSettings settings;
  final dynamic labels;
  final ValueChanged<BookSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final typography = settings.typography;
    return _SettingsSection(
      title: labels.title as String,
      icon: Icons.text_fields_outlined,
      children: [
        DropdownButtonFormField<String>(
          initialValue: typography.fontFamily ?? 'system',
          decoration: InputDecoration(labelText: labels.fontFamily as String),
          items: [
            DropdownMenuItem(value: 'system', child: Text(labels.fontFamilies.system)),
            DropdownMenuItem(value: 'serif', child: Text(labels.fontFamilies.serif)),
            DropdownMenuItem(
              value: 'sans-serif',
              child: Text(labels.fontFamilies.sansSerif),
            ),
            DropdownMenuItem(
              value: 'monospace',
              child: Text(labels.fontFamilies.monospace),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            onChanged(
              settings.copyWith(
                typography: typography.copyWith(
                  fontFamily: value == 'system' ? null : value,
                  clearFontFamily: value == 'system',
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _TwoColumns(
          first: _DoubleDropdown(
            label: labels.fontSize as String,
            value: typography.fontSize,
            values: const [10, 11, 12, 13, 14, 16, 18, 20],
            onChanged: (value) => onChanged(
              settings.copyWith(
                typography: typography.copyWith(fontSize: value),
              ),
            ),
          ),
          second: DropdownButtonFormField<int>(
            initialValue: typography.fontWeight,
            decoration: InputDecoration(labelText: labels.fontWeight as String),
            items: const [300, 400, 500, 600, 700]
                .map((value) => DropdownMenuItem(value: value, child: Text('$value')))
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              onChanged(
                settings.copyWith(
                  typography: typography.copyWith(fontWeight: value),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _TwoColumns(
          first: _DoubleDropdown(
            label: labels.lineHeight as String,
            value: typography.lineHeight,
            values: const [1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2.0],
            suffix: '',
            onChanged: (value) => onChanged(
              settings.copyWith(
                typography: typography.copyWith(lineHeight: value),
              ),
            ),
          ),
          second: DropdownButtonFormField<BookTextAlignment>(
            initialValue: typography.alignment,
            decoration: InputDecoration(labelText: labels.alignment as String),
            items: [
              DropdownMenuItem(
                value: BookTextAlignment.start,
                child: Text(labels.alignmentValues.start),
              ),
              DropdownMenuItem(
                value: BookTextAlignment.left,
                child: Text(labels.alignmentValues.left),
              ),
              DropdownMenuItem(
                value: BookTextAlignment.center,
                child: Text(labels.alignmentValues.center),
              ),
              DropdownMenuItem(
                value: BookTextAlignment.right,
                child: Text(labels.alignmentValues.right),
              ),
              DropdownMenuItem(
                value: BookTextAlignment.justify,
                child: Text(labels.alignmentValues.justify),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              onChanged(
                settings.copyWith(
                  typography: typography.copyWith(alignment: value),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

final class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

final class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              first,
              const SizedBox(height: 16),
              second,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 16),
            Expanded(child: second),
          ],
        );
      },
    );
  }
}

final class _DoubleDropdown extends StatelessWidget {
  const _DoubleDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.suffix = ' pt',
  });

  final String label;
  final double value;
  final List<num> values;
  final ValueChanged<double> onChanged;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<double>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem(
            value: item.toDouble(),
            child: Text('$item$suffix'),
          ),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
