import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CommandButton(
            tooltip: 'Heading 1',
            label: 'H1',
            onPressed: () => _insert('\n# Heading\n', cursorOffset: 3),
          ),
          _CommandButton(
            tooltip: 'Heading 2',
            label: 'H2',
            onPressed: () => _insert('\n## Heading\n', cursorOffset: 4),
          ),
          _CommandButton(
            tooltip: 'Bold',
            icon: Icons.format_bold,
            onPressed: () => _wrapSelection('**', '**', 'bold text'),
          ),
          _CommandButton(
            tooltip: 'Italic',
            icon: Icons.format_italic,
            onPressed: () => _wrapSelection('*', '*', 'italic text'),
          ),
          _CommandButton(
            tooltip: 'Bullet list',
            icon: Icons.format_list_bulleted,
            onPressed: () => _insert('\n- Item one\n- Item two\n'),
          ),
          _CommandButton(
            tooltip: 'Numbered list',
            icon: Icons.format_list_numbered,
            onPressed: () => _insert('\n1. First item\n2. Second item\n'),
          ),
          _CommandButton(
            tooltip: 'Quote',
            icon: Icons.format_quote,
            onPressed: () => _insert('\n> Quote\n'),
          ),
          _CommandButton(
            tooltip: 'Link',
            icon: Icons.link,
            onPressed: () => _insert(
              '[Link text](https://example.com)',
              cursorOffset: 1,
            ),
          ),
          _CommandButton(
            tooltip: 'Image',
            icon: Icons.image_outlined,
            onPressed: () => _insert(
              '![Image description](assets/images/image.png)',
              cursorOffset: 2,
            ),
          ),
          _CommandButton(
            tooltip: 'Table',
            icon: Icons.table_chart_outlined,
            onPressed: () => _insert('''

| Column 1 | Column 2 | Column 3 |
|---|---|---|
| Value 1 | Value 2 | Value 3 |
| Value 4 | Value 5 | Value 6 |
'''),
          ),
          _CommandButton(
            tooltip: 'Code block',
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
            tooltip: 'Divider',
            icon: Icons.horizontal_rule,
            onPressed: () => _insert('\n\n---\n\n'),
          ),
          _CommandButton(
            tooltip: 'New page',
            icon: Icons.note_add_outlined,
            onPressed: () => _insert('\n\n<!-- page -->\n\n'),
          ),
          _CommandButton(
            tooltip: 'New page with settings',
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
      padding: const EdgeInsets.only(right: 4),
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
