import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/features/book_editor/application/template_registry.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookSettingsPage extends StatefulWidget {
  const BookSettingsPage({required this.settings, super.key});

  final BookSettings settings;

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

  String _orientationLabel(
    BookPageOrientation orientation,
    Translations tr,
  ) {
    return switch (orientation) {
      BookPageOrientation.portrait =>
        tr.bookSettings.sections.document.orientationValues.portrait,
      BookPageOrientation.landscape =>
        tr.bookSettings.sections.document.orientationValues.landscape,
    };
  }

  String _alignmentLabel(
    BookTextAlignment alignment,
    Translations tr,
  ) {
    final values = tr.bookSettings.sections.typography.alignmentValues;
    return switch (alignment) {
      BookTextAlignment.start => values.start,
      BookTextAlignment.left => values.left,
      BookTextAlignment.center => values.center,
      BookTextAlignment.right => values.right,
      BookTextAlignment.justify => values.justify,
    };
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = TemplateRegistry.descriptor(_settings.templateId);
    final typography = _settings.typography;
    final tr = Translations.of(context);
    final document = tr.bookSettings.sections.document;
    final language = tr.bookSettings.sections.language;
    final type = tr.bookSettings.sections.typography;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.bookSettings.page.title),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_settings),
              icon: const Icon(Icons.check),
              label: Text(tr.app.actions.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<BookPageSize>(
                            initialValue: _settings.pageSize,
                            decoration: InputDecoration(
                              labelText: document.pageSize,
                            ),
                            items: [
                              for (final size in BookPageSize.values)
                                DropdownMenuItem(
                                  value: size,
                                  child: Text(size.name.toUpperCase()),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(
                                () => _settings = _settings.copyWith(
                                  pageSize: value,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<BookPageOrientation>(
                            initialValue: _settings.orientation,
                            decoration: InputDecoration(
                              labelText: document.orientation,
                            ),
                            items: [
                              for (final value in BookPageOrientation.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(_orientationLabel(value, tr)),
                                ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(
                                () => _settings = _settings.copyWith(
                                  orientation: value,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: _settings.margin,
                            decoration: InputDecoration(
                              labelText: document.pageMargin,
                            ),
                            items: const [12, 18, 24, 30, 36, 48, 60]
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
                                () => _settings = _settings.copyWith(
                                  margin: value,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: _settings.contentPadding,
                            decoration: InputDecoration(
                              labelText: document.contentPadding,
                            ),
                            items: const [0, 8, 12, 18, 24, 36, 48]
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
                                () => _settings = _settings.copyWith(
                                  contentPadding: value,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _settings.defaultColumns,
                      decoration: InputDecoration(
                        labelText: document.columns.title,
                        helperText: document.columns.helper,
                      ),
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
                          () => _settings = _settings.copyWith(
                            defaultColumns: value,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: language.title,
                  icon: Icons.language_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _settings.languageCode,
                            decoration: InputDecoration(
                              labelText: language.bookLanguage,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(tr.language.locales.en),
                              ),
                              DropdownMenuItem(
                                value: 'ar',
                                child: Text(tr.language.locales.ar),
                              ),
                              DropdownMenuItem(
                                value: 'fr',
                                child: Text(tr.language.locales.fr),
                              ),
                              DropdownMenuItem(
                                value: 'de',
                                child: Text(tr.language.locales.de),
                              ),
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
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<BookDirection>(
                            initialValue: _settings.direction,
                            decoration: InputDecoration(
                              labelText: language.direction,
                            ),
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
                              setState(
                                () => _settings = _settings.copyWith(
                                  direction: value,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: type.title,
                  icon: Icons.text_fields_outlined,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: typography.fontFamily ?? 'system',
                      decoration: InputDecoration(labelText: type.fontFamily),
                      items: [
                        DropdownMenuItem(
                          value: 'system',
                          child: Text(type.fontFamilies.system),
                        ),
                        DropdownMenuItem(
                          value: 'serif',
                          child: Text(type.fontFamilies.serif),
                        ),
                        DropdownMenuItem(
                          value: 'sans-serif',
                          child: Text(type.fontFamilies.sansSerif),
                        ),
                        DropdownMenuItem(
                          value: 'monospace',
                          child: Text(type.fontFamilies.monospace),
                        ),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: typography.fontSize,
                            decoration: InputDecoration(labelText: type.fontSize),
                            items: const [10, 11, 12, 13, 14, 16, 18, 20]
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: typography.fontWeight,
                            decoration: InputDecoration(
                              labelText: type.fontWeight,
                            ),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: typography.lineHeight,
                            decoration: InputDecoration(labelText: type.lineHeight),
                            items: const [1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2.0]
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<BookTextAlignment>(
                            initialValue: typography.alignment,
                            decoration: InputDecoration(labelText: type.alignment),
                            items: [
                              for (final value in BookTextAlignment.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(_alignmentLabel(value, tr)),
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
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: tr.bookSettings.sections.templateBehavior.title,
                  icon: Icons.auto_awesome_outlined,
                  children: [
                    Text(
                      tr.bookSettings.sections.templateBehavior
                          .chapterOpeningLayout(
                        layout: descriptor.chapterLayouts.first,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
