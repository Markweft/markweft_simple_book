from pathlib import Path

page_path = Path('lib/features/book_editor/presentation/pages/book_editor_page.dart')
text = page_path.read_text()
original = text

old_import = "import 'package:markweft_simple_book/features/book_editor/presentation/widgets/markdown_command_toolbar.dart';\n"
new_import = "import 'package:markweft_simple_book/features/book_editor/presentation/widgets/smart_markdown_editor.dart';\n"
text = text.replace(old_import, '')
if new_import not in text:
    anchor = "import 'package:markweft_simple_book/features/book_editor/presentation/widgets/book_settings_dialog.dart';\n"
    text = text.replace(anchor, anchor + new_import, 1)

text = text.replace(
    '  late final TextEditingController _controller;\n',
    '  late final SmartMarkdownController _controller;\n',
    1,
)
text = text.replace(
    '    _controller = TextEditingController();\n',
    '    _controller = SmartMarkdownController();\n',
    1,
)

start_marker = 'final class _MarkdownEditor extends StatelessWidget {'
end_marker = 'final class _BookSidebar extends StatelessWidget {'
start = text.find(start_marker)
end = text.find(end_marker)
if start < 0 or end < 0 or end <= start:
    raise SystemExit('Markdown editor block markers not found')

replacement = r'''final class _MarkdownEditor extends StatelessWidget {
  const _MarkdownEditor({
    required this.controller,
    required this.chapterTitle,
    required this.actions,
    required this.onChanged,
  });

  final SmartMarkdownController controller;
  final String? chapterTitle;
  final Set<TemplateToolbarAction> actions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapterTitle == null
                            ? tr.editor.workspace.markdown.title
                            : tr.editor.workspace.markdown
                                .chapterTitle(title: chapterTitle!),
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tr.toolbar.smart.help,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: tr.editor.workspace.markdown.chapterOnlyLoaded,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 15, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          tr.toolbar.smart.live,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SmartMarkdownEditor(
                controller: controller,
                actions: actions,
                onChanged: onChanged,
                hintText: tr.editor.workspace.markdown.writeHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'''

if 'final SmartMarkdownController controller;' not in text[start:end] or 'tr.toolbar.smart.help' not in text[start:end]:
    text = text[:start] + replacement + text[end:]

if text != original:
    page_path.write_text(text)

smart_path = Path('lib/features/book_editor/presentation/widgets/smart_markdown_editor.dart')
smart = smart_path.read_text()
smart_original = smart
smart = smart.replace("        const _SlashCommand(\n          label: 'Table',", "        _SlashCommand(\n          label: tr.toolbar.insert.table,")
smart = smart.replace("        const _SlashCommand(\n          label: 'Code block',", "        _SlashCommand(\n          label: tr.toolbar.formatting.codeBlock,")
smart = smart.replace("        label: 'Underline',", "        label: tr.toolbar.formatting.underline,")
smart = smart.replace("        label: 'Strike',", "        label: tr.toolbar.formatting.strike,")
smart = smart.replace("        label: 'Code',", "        label: tr.toolbar.formatting.inlineCode,")

build_marker = '''  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
'''
if '_buildFloatingSelectionToolbar' not in smart and build_marker in smart:
    helper = r'''  Widget _buildFloatingSelectionToolbar(BuildContext context) {
    final tr = Translations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget action({
      required String tooltip,
      required Widget icon,
      required VoidCallback onPressed,
    }) {
      return Tooltip(
        message: tooltip,
        child: IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: icon,
        ),
      );
    }

    return Material(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.28),
      color: scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            action(
              tooltip: tr.toolbar.formatting.bold,
              icon: const Icon(Icons.format_bold_rounded, size: 18),
              onPressed: () => _wrapSelection(
                '**',
                '**',
                fallback: tr.toolbar.placeholders.boldText,
              ),
            ),
            action(
              tooltip: tr.toolbar.formatting.italic,
              icon: const Icon(Icons.format_italic_rounded, size: 18),
              onPressed: () => _wrapSelection(
                '*',
                '*',
                fallback: tr.toolbar.placeholders.italicText,
              ),
            ),
            action(
              tooltip: tr.toolbar.formatting.underline,
              icon: const Icon(Icons.format_underlined_rounded, size: 18),
              onPressed: () => _wrapSelection('<u>', '</u>'),
            ),
            action(
              tooltip: tr.toolbar.formatting.strike,
              icon: const Icon(Icons.strikethrough_s_rounded, size: 18),
              onPressed: () => _wrapSelection('~~', '~~'),
            ),
            action(
              tooltip: tr.toolbar.formatting.inlineCode,
              icon: const Icon(Icons.code_rounded, size: 18),
              onPressed: () => _wrapSelection('`', '`'),
            ),
            if (widget.actions.contains(TemplateToolbarAction.link))
              action(
                tooltip: tr.toolbar.insert.link,
                icon: const Icon(Icons.link_rounded, size: 18),
                onPressed: () => _wrapSelection(
                  '[',
                  '](https://example.com)',
                  fallback: tr.toolbar.placeholders.linkText,
                ),
              ),
          ],
        ),
      ),
    );
  }

'''
    smart = smart.replace(build_marker, helper + build_marker, 1)

old_return = '''    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
'''
new_return = '''    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        children: [
          Positioned.fill(
            child: TextField(
'''
smart = smart.replace(old_return, new_return, 1)

old_tail = '''        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 15.5,
          height: 1.65,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
'''
new_tail = '''        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 15.5,
          height: 1.65,
          color: scheme.onSurface,
        ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final selection = value.selection;
              if (!selection.isValid || selection.isCollapsed) {
                return const SizedBox.shrink();
              }
              return Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _buildFloatingSelectionToolbar(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
'''
if 'ValueListenableBuilder<TextEditingValue>' not in smart:
    if old_tail not in smart:
        raise SystemExit('Smart editor build tail marker not found')
    smart = smart.replace(old_tail, new_tail, 1)

if smart != smart_original:
    smart_path.write_text(smart)
