from pathlib import Path

path = Path('lib/features/book_editor/presentation/pages/book_editor_page.dart')
text = path.read_text()
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
                        'Live Markdown · Select text for formatting · Type / for blocks',
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
                          'Live',
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

if 'final SmartMarkdownController controller;' not in text[start:end]:
    text = text[:start] + replacement + text[end:]

if text != original:
    path.write_text(text)
