import 'package:flutter/material.dart';

final class MarkdownCommandToolbar extends StatelessWidget {
  const MarkdownCommandToolbar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  void _insert(String value) {
    final selection = controller.selection;
    final text = controller.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final selectedText = start == end ? '' : text.substring(start, end);
    final replacement = value.replaceFirst('{{selection}}', selectedText);

    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, replacement),
      selection: TextSelection.collapsed(offset: start + replacement.length),
    );
    onChanged(controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CommandButton(
            tooltip: 'Heading 1',
            icon: Icons.title,
            label: 'H1',
            onPressed: () => _insert('# {{selection}}'),
          ),
          _CommandButton(
            tooltip: 'Heading 2',
            icon: Icons.title,
            label: 'H2',
            onPressed: () => _insert('## {{selection}}'),
          ),
          _CommandButton(
            tooltip: 'Bold',
            icon: Icons.format_bold,
            onPressed: () => _insert('**{{selection}}**'),
          ),
          _CommandButton(
            tooltip: 'Italic',
            icon: Icons.format_italic,
            onPressed: () => _insert('*{{selection}}*'),
          ),
          _CommandButton(
            tooltip: 'Bullet list',
            icon: Icons.format_list_bulleted,
            onPressed: () => _insert('- {{selection}}'),
          ),
          _CommandButton(
            tooltip: 'Numbered list',
            icon: Icons.format_list_numbered,
            onPressed: () => _insert('1. {{selection}}'),
          ),
          _CommandButton(
            tooltip: 'Quote',
            icon: Icons.format_quote,
            onPressed: () => _insert('> {{selection}}'),
          ),
          _CommandButton(
            tooltip: 'Link',
            icon: Icons.link,
            onPressed: () => _insert('[{{selection}}](https://example.com)'),
          ),
          _CommandButton(
            tooltip: 'Image',
            icon: Icons.image_outlined,
            onPressed: () => _insert('![Description](assets/images/image.png)'),
          ),
          _CommandButton(
            tooltip: 'Table',
            icon: Icons.table_chart_outlined,
            onPressed: () => _insert(
              '| Column 1 | Column 2 | Column 3 |\n'
              '|---|---|---|\n'
              '| Value 1 | Value 2 | Value 3 |\n'
              '| Value 4 | Value 5 | Value 6 |',
            ),
          ),
          _CommandButton(
            tooltip: 'New page',
            icon: Icons.note_add_outlined,
            label: 'Page',
            onPressed: () => _insert('\n\n<!-- page -->\n\n'),
          ),
          _CommandButton(
            tooltip: 'New page with settings',
            icon: Icons.tune,
            label: 'Page+',
            onPressed: () => _insert(
              '\n\n<!-- page\n'
              'size: a4\n'
              'orientation: portrait\n'
              'margin: 24\n'
              'padding: 48\n'
              'layout: default\n'
              '-->\n\n',
            ),
          ),
          _CommandButton(
            tooltip: 'Horizontal rule',
            icon: Icons.horizontal_rule,
            onPressed: () => _insert('\n\n---\n\n'),
          ),
          _CommandButton(
            tooltip: 'Code block',
            icon: Icons.code,
            onPressed: () => _insert('```\n{{selection}}\n```'),
          ),
        ],
      ),
    );
  }
}

final class _CommandButton extends StatelessWidget {
  const _CommandButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: label == null
            ? IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onPressed,
                icon: Icon(icon, size: 19),
              )
            : TextButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label!),
              ),
      ),
    );
  }
}
