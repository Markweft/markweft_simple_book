import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final descriptor = TemplateRegistry.descriptor(_settings.templateId);
    final typography = _settings.typography;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book settings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(_settings),
              icon: const Icon(Icons.check),
              label: const Text('Save'),
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
                  title: 'Document',
                  icon: Icons.description_outlined,
                  children: [
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<BookPageSize>(
                            initialValue: _settings.pageSize,
                            decoration: const InputDecoration(
                              labelText: 'Page size',
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
                            decoration: const InputDecoration(
                              labelText: 'Orientation',
                            ),
                            items: [
                              for (final value in BookPageOrientation.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(value.name),
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
                            decoration: const InputDecoration(
                              labelText: 'Page margin',
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
                            decoration: const InputDecoration(
                              labelText: 'Content padding',
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
                      decoration: const InputDecoration(
                        labelText: 'Default columns',
                        helperText: 'Available column counts are defined by the selected template.',
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
                  title: 'Language & direction',
                  icon: Icons.language_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _settings.languageCode,
                            decoration: const InputDecoration(
                              labelText: 'Book language',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text('English')),
                              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
                              DropdownMenuItem(value: 'fr', child: Text('French')),
                              DropdownMenuItem(value: 'de', child: Text('German')),
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
                            decoration: const InputDecoration(
                              labelText: 'Direction',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: BookDirection.ltr,
                                child: Text('Left to right (LTR)'),
                              ),
                              DropdownMenuItem(
                                value: BookDirection.rtl,
                                child: Text('Right to left (RTL)'),
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
                  title: 'Typography',
                  icon: Icons.text_fields_outlined,
                  children: [
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: typography.fontSize,
                            decoration: const InputDecoration(labelText: 'Font size'),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<double>(
                            initialValue: typography.lineHeight,
                            decoration: const InputDecoration(labelText: 'Line height'),
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
                            decoration: const InputDecoration(labelText: 'Alignment'),
                            items: [
                              for (final value in BookTextAlignment.values)
                                DropdownMenuItem(
                                  value: value,
                                  child: Text(value.name),
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
                  title: 'Template behavior',
                  icon: Icons.auto_awesome_outlined,
                  children: [
                    Text(
                      'Chapter opening pages use the template-specific '
                      '${descriptor.chapterLayouts.first} layout by default.',
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
