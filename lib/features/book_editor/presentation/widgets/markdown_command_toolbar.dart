import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';

final class MarkdownCommandToolbar extends StatelessWidget {
  const MarkdownCommandToolbar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _insert(String text, {int? cursorOffset}) {
    final value = controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final start = selection.start.clamp(0, value.text.length);
    final end = selection.end.clamp(0, value.text.length);
    final nextText = value.text.replaceRange(start, end, text);
    final nextOffset = (start + (cursorOffset ?? text.length)).clamp(
      0,
      nextText.length,
    );

    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextOffset),
    );
    onChanged(nextText);
  }

  void _wrapSelection(String before, String after, String fallback) {
    final value = controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final start = selection.start.clamp(0, value.text.length);
    final end = selection.end.clamp(0, value.text.length);
    final selected = start == end ? fallback : value.text.substring(start, end);
    final replacement = '$before$selected$after';
    final nextText = value.text.replaceRange(start, end, replacement);

    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection(
        baseOffset: start + before.length,
        extentOffset: start + before.length + selected.length,
      ),
    );
    onChanged(nextText);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CommandButton(
            tooltip: tr.toolbar.headings.h1,
            label: 'H1',
            onPressed: () => _insert(
              '\n# ${tr.toolbar.headings.placeholder}\n',
              cursorOffset: 3,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.headings.h2,
            label: 'H2',
            onPressed: () => _insert(
              '\n## ${tr.toolbar.headings.placeholder}\n',
              cursorOffset: 4,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.formatting.bold,
            icon: Icons.format_bold,
            onPressed: () => _wrapSelection(
              '**',
              '**',
              tr.toolbar.placeholders.boldText,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.formatting.italic,
            icon: Icons.format_italic,
            onPressed: () => _wrapSelection(
              '*',
              '*',
              tr.toolbar.placeholders.italicText,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.lists.bullet,
            icon: Icons.format_list_bulleted,
            onPressed: () => _insert(
              '\n- ${tr.toolbar.lists.itemOne}\n- ${tr.toolbar.lists.itemTwo}\n',
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.lists.numbered,
            icon: Icons.format_list_numbered,
            onPressed: () => _insert(
              '\n1. ${tr.toolbar.lists.firstItem}\n2. ${tr.toolbar.lists.secondItem}\n',
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.formatting.quote,
            icon: Icons.format_quote,
            onPressed: () =>
                _insert('\n> ${tr.toolbar.placeholders.quoteText}\n'),
          ),
          _CommandButton(
            tooltip: tr.toolbar.insert.link,
            icon: Icons.link,
            onPressed: () => _insert(
              '[${tr.toolbar.placeholders.linkText}](https://example.com)',
              cursorOffset: 1,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.insert.image,
            icon: Icons.image_outlined,
            onPressed: () => _insert(
              '![${tr.toolbar.placeholders.imageDescription}](assets/images/image.png)',
              cursorOffset: 2,
            ),
          ),
          _CommandButton(
            tooltip: tr.toolbar.insert.table,
            icon: Icons.table_chart_outlined,
            onPressed: () => _insert('''

| Column 1 | Column 2 | Column 3 |
|---|---|---|
| Value 1 | Value 2 | Value 3 |
| Value 4 | Value 5 | Value 6 |
'''),
          ),
          _CommandButton(
            tooltip: tr.toolbar.formatting.codeBlock,
            icon: Icons.code,
            onPressed: () => _insert('''

```dart
void main() {
  print('Hello');
}
```
'''),
          ),
          _CommandButton(
            tooltip: tr.toolbar.formatting.divider,
            icon: Icons.horizontal_rule,
            onPressed: () => _insert('\n\n---\n\n'),
          ),
          _CommandButton(
            tooltip: tr.toolbar.insert.newPage,
            icon: Icons.note_add_outlined,
            onPressed: () => _insert('\n\n<!-- page -->\n\n'),
          ),
          _CommandButton(
            tooltip: tr.toolbar.insert.newPageWithSettings,
            icon: Icons.tune,
            onPressed: () => _insert('''

<!-- page
size: a4
orientation: portrait
margin: 24
padding: 48
layout: default
-->

'''),
          ),
        ],
      ),
    );
  }
}

final class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.label,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: Tooltip(
        message: tooltip,
        child: IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: onPressed,
          icon: icon == null
              ? Text(
                  label!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                )
              : Icon(icon, size: 19),
        ),
      ),
    );
  }
}
