import 'package:flutter/material.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class SmartMarkdownController extends TextEditingController {
  SmartMarkdownController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    final scheme = Theme.of(context).colorScheme;
    final children = <InlineSpan>[];
    final lines = text.split('\n');

    for (var index = 0; index < lines.length; index++) {
      _appendStyledLine(
        children,
        lines[index],
        baseStyle: baseStyle,
        scheme: scheme,
      );
      if (index < lines.length - 1) {
        children.add(TextSpan(text: '\n', style: baseStyle));
      }
    }

    return TextSpan(style: baseStyle, children: children);
  }

  void _appendStyledLine(
    List<InlineSpan> children,
    String line, {
    required TextStyle baseStyle,
    required ColorScheme scheme,
  }) {
    final headingMatch = RegExp(r'^(#{1,6})(\s+)(.*)$').firstMatch(line);
    if (headingMatch != null) {
      final level = headingMatch.group(1)!.length;
      final sizes = <int, double>{
        1: 30,
        2: 25,
        3: 21,
        4: 18,
        5: 16,
        6: 15,
      };
      children
        ..add(
          TextSpan(
            text: '${headingMatch.group(1)}${headingMatch.group(2)}',
            style: baseStyle.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.38),
              fontSize: sizes[level],
              fontWeight: FontWeight.w700,
            ),
          ),
        )
        ..add(
          TextSpan(
            text: headingMatch.group(3),
            style: baseStyle.copyWith(
              color: scheme.onSurface,
              fontSize: sizes[level],
              height: 1.25,
              fontWeight: level <= 2 ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: level <= 2 ? -0.35 : null,
            ),
          ),
        );
      return;
    }

    final quoteMatch = RegExp(r'^(>)(\s?)(.*)$').firstMatch(line);
    if (quoteMatch != null) {
      children
        ..add(
          TextSpan(
            text: '${quoteMatch.group(1)}${quoteMatch.group(2)}',
            style: baseStyle.copyWith(
              color: scheme.primary.withValues(alpha: 0.65),
              fontWeight: FontWeight.w700,
            ),
          ),
        )
        ..add(
          TextSpan(
            text: quoteMatch.group(3),
            style: baseStyle.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      return;
    }

    final listMatch = RegExp(r'^(\s*)([-*+] |\d+\. )(.*)$').firstMatch(line);
    if (listMatch != null) {
      children
        ..add(TextSpan(text: listMatch.group(1), style: baseStyle))
        ..add(
          TextSpan(
            text: listMatch.group(2),
            style: baseStyle.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      _appendInlineStyles(
        children,
        listMatch.group(3) ?? '',
        baseStyle: baseStyle,
        scheme: scheme,
      );
      return;
    }

    if (RegExp(r'^\s*(---|___|\*\*\*)\s*$').hasMatch(line)) {
      children.add(
        TextSpan(
          text: line,
          style: baseStyle.copyWith(
            color: scheme.outline,
            letterSpacing: 2,
          ),
        ),
      );
      return;
    }

    if (line.trimLeft().startsWith('<!--')) {
      children.add(
        TextSpan(
          text: line,
          style: baseStyle.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.52),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
      return;
    }

    _appendInlineStyles(
      children,
      line,
      baseStyle: baseStyle,
      scheme: scheme,
    );
  }

  void _appendInlineStyles(
    List<InlineSpan> children,
    String value, {
    required TextStyle baseStyle,
    required ColorScheme scheme,
  }) {
    final pattern = RegExp(
      r'(\*\*[^*\n]+\*\*|~~[^~\n]+~~|`[^`\n]+`|\*[^*\n]+\*|_[^_\n]+_|\[[^\]\n]+\]\([^\)\n]+\))',
    );
    var cursor = 0;

    for (final match in pattern.allMatches(value)) {
      if (match.start > cursor) {
        children.add(
          TextSpan(text: value.substring(cursor, match.start), style: baseStyle),
        );
      }

      final token = match.group(0)!;
      if (token.startsWith('**')) {
        _appendDelimited(
          children,
          token,
          delimiterLength: 2,
          contentStyle: baseStyle.copyWith(fontWeight: FontWeight.w700),
          markerStyle: baseStyle.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        );
      } else if (token.startsWith('~~')) {
        _appendDelimited(
          children,
          token,
          delimiterLength: 2,
          contentStyle: baseStyle.copyWith(
            decoration: TextDecoration.lineThrough,
          ),
          markerStyle: baseStyle.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        );
      } else if (token.startsWith('`')) {
        _appendDelimited(
          children,
          token,
          delimiterLength: 1,
          contentStyle: baseStyle.copyWith(
            fontFamily: 'monospace',
            color: scheme.tertiary,
            backgroundColor: scheme.tertiaryContainer.withValues(alpha: 0.22),
          ),
          markerStyle: baseStyle.copyWith(
            color: scheme.tertiary.withValues(alpha: 0.45),
          ),
        );
      } else if (token.startsWith('*') || token.startsWith('_')) {
        _appendDelimited(
          children,
          token,
          delimiterLength: 1,
          contentStyle: baseStyle.copyWith(fontStyle: FontStyle.italic),
          markerStyle: baseStyle.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.35),
          ),
        );
      } else {
        children.add(
          TextSpan(
            text: token,
            style: baseStyle.copyWith(
              color: scheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: scheme.primary.withValues(alpha: 0.5),
            ),
          ),
        );
      }

      cursor = match.end;
    }

    if (cursor < value.length) {
      children.add(TextSpan(text: value.substring(cursor), style: baseStyle));
    }
  }

  void _appendDelimited(
    List<InlineSpan> children,
    String token, {
    required int delimiterLength,
    required TextStyle contentStyle,
    required TextStyle markerStyle,
  }) {
    final marker = token.substring(0, delimiterLength);
    final content = token.substring(delimiterLength, token.length - delimiterLength);
    children
      ..add(TextSpan(text: marker, style: markerStyle))
      ..add(TextSpan(text: content, style: contentStyle))
      ..add(TextSpan(text: marker, style: markerStyle));
  }
}

final class SmartMarkdownEditor extends StatefulWidget {
  const SmartMarkdownEditor({
    required this.controller,
    required this.actions,
    required this.onChanged,
    required this.hintText,
    super.key,
  });

  final SmartMarkdownController controller;
  final Set<TemplateToolbarAction> actions;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<SmartMarkdownEditor> createState() => _SmartMarkdownEditorState();
}

final class _SmartMarkdownEditorState extends State<SmartMarkdownEditor> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _slashOverlay;
  String _slashQuery = '';
  int? _slashStart;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SmartMarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleControllerChanged);
      widget.controller.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _removeSlashOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    final value = widget.controller.value;
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      _removeSlashOverlay();
      return;
    }

    final caret = selection.extentOffset.clamp(0, value.text.length);
    final lineStart = caret == 0 ? 0 : value.text.lastIndexOf('\n', caret - 1) + 1;
    final beforeCaret = value.text.substring(lineStart, caret);
    final match = RegExp(r'(^|\s)/([\w-]*)$').firstMatch(beforeCaret);
    if (match == null) {
      _removeSlashOverlay();
      return;
    }

    _slashQuery = (match.group(2) ?? '').toLowerCase();
    _slashStart = lineStart + match.start + (match.group(1)?.length ?? 0);
    _showSlashOverlay();
  }

  void _showSlashOverlay() {
    if (!mounted) return;
    if (_slashOverlay == null) {
      _slashOverlay = OverlayEntry(builder: _buildSlashOverlay);
      Overlay.of(context).insert(_slashOverlay!);
    } else {
      _slashOverlay!.markNeedsBuild();
    }
  }

  void _removeSlashOverlay() {
    _slashOverlay?.remove();
    _slashOverlay = null;
    _slashStart = null;
    _slashQuery = '';
  }

  List<_SlashCommand> _commands(BuildContext context) {
    final tr = Translations.of(context);
    final all = <_SlashCommand>[
      if (widget.actions.contains(TemplateToolbarAction.heading1))
        _SlashCommand(
          label: tr.toolbar.headings.h1,
          keywords: const ['h1', 'heading', 'title'],
          icon: Icons.title_rounded,
          insertion: '# ${tr.toolbar.headings.placeholder}',
        ),
      if (widget.actions.contains(TemplateToolbarAction.heading2))
        _SlashCommand(
          label: tr.toolbar.headings.h2,
          keywords: const ['h2', 'heading', 'subtitle'],
          icon: Icons.text_fields_rounded,
          insertion: '## ${tr.toolbar.headings.placeholder}',
        ),
      if (widget.actions.contains(TemplateToolbarAction.bulletList))
        _SlashCommand(
          label: tr.toolbar.lists.bullet,
          keywords: const ['list', 'bullet', 'ul'],
          icon: Icons.format_list_bulleted_rounded,
          insertion: '- ',
        ),
      if (widget.actions.contains(TemplateToolbarAction.numberedList))
        _SlashCommand(
          label: tr.toolbar.lists.numbered,
          keywords: const ['list', 'number', 'ol'],
          icon: Icons.format_list_numbered_rounded,
          insertion: '1. ',
        ),
      if (widget.actions.contains(TemplateToolbarAction.quote))
        _SlashCommand(
          label: tr.toolbar.formatting.quote,
          keywords: const ['quote', 'blockquote'],
          icon: Icons.format_quote_rounded,
          insertion: '> ',
        ),
      if (widget.actions.contains(TemplateToolbarAction.image))
        _SlashCommand(
          label: tr.toolbar.insert.image,
          keywords: const ['image', 'picture', 'photo'],
          icon: Icons.image_outlined,
          insertion:
              '![${tr.toolbar.placeholders.imageDescription}](assets/images/image.png)',
        ),
      if (widget.actions.contains(TemplateToolbarAction.link))
        _SlashCommand(
          label: tr.toolbar.insert.link,
          keywords: const ['link', 'url'],
          icon: Icons.link_rounded,
          insertion:
              '[${tr.toolbar.placeholders.linkText}](https://example.com)',
        ),
      if (widget.actions.contains(TemplateToolbarAction.table))
        const _SlashCommand(
          label: 'Table',
          keywords: ['table', 'grid'],
          icon: Icons.table_chart_outlined,
          insertion:
              '| Column 1 | Column 2 |\n| --- | --- |\n| Value 1 | Value 2 |',
        ),
      if (widget.actions.contains(TemplateToolbarAction.codeBlock))
        const _SlashCommand(
          label: 'Code block',
          keywords: ['code', 'block', 'snippet'],
          icon: Icons.code_rounded,
          insertion: '```\n\n```',
          cursorBack: 4,
        ),
      if (widget.actions.contains(TemplateToolbarAction.divider))
        _SlashCommand(
          label: tr.toolbar.formatting.divider,
          keywords: const ['divider', 'rule', 'separator'],
          icon: Icons.horizontal_rule_rounded,
          insertion: '---',
        ),
      if (widget.actions.contains(TemplateToolbarAction.newPage))
        _SlashCommand(
          label: tr.toolbar.insert.newPage,
          keywords: const ['page', 'break', 'new page'],
          icon: Icons.note_add_outlined,
          insertion: '<!-- page -->',
        ),
    ];

    if (_slashQuery.isEmpty) return all;
    return all
        .where(
          (command) => command.label.toLowerCase().contains(_slashQuery) ||
              command.keywords.any((keyword) => keyword.contains(_slashQuery)),
        )
        .toList(growable: false);
  }

  Widget _buildSlashOverlay(BuildContext context) {
    final commands = _commands(context);
    if (commands.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(18, 56),
        child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 12,
            shadowColor: Colors.black.withValues(alpha: 0.28),
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 280,
                maxWidth: 340,
                maxHeight: 360,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(command.icon, size: 19),
                    title: Text(command.label),
                    onTap: () => _applySlashCommand(command),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _applySlashCommand(_SlashCommand command) {
    final start = _slashStart;
    if (start == null) return;
    final value = widget.controller.value;
    final end = value.selection.extentOffset.clamp(start, value.text.length);
    final nextText = value.text.replaceRange(start, end, command.insertion);
    final offset = (start + command.insertion.length - command.cursorBack)
        .clamp(0, nextText.length);
    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: offset),
    );
    widget.onChanged(nextText);
    _removeSlashOverlay();
    _focusNode.requestFocus();
  }

  void _wrapSelection(String before, String after, {String fallback = 'text'}) {
    final value = widget.controller.value;
    final selection = value.selection;
    if (!selection.isValid) return;
    final start = selection.start.clamp(0, value.text.length);
    final end = selection.end.clamp(0, value.text.length);
    final selected = start == end ? fallback : value.text.substring(start, end);
    final replacement = '$before$selected$after';
    final nextText = value.text.replaceRange(start, end, replacement);
    widget.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection(
        baseOffset: start + before.length,
        extentOffset: start + before.length + selected.length,
      ),
    );
    widget.onChanged(nextText);
  }

  List<ContextMenuButtonItem> _contextMenuItems(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    final tr = Translations.of(context);
    return <ContextMenuButtonItem>[
      ContextMenuButtonItem(
        label: tr.toolbar.formatting.bold,
        onPressed: () {
          ContextMenuController.removeAny();
          _wrapSelection('**', '**', fallback: tr.toolbar.placeholders.boldText);
        },
      ),
      ContextMenuButtonItem(
        label: tr.toolbar.formatting.italic,
        onPressed: () {
          ContextMenuController.removeAny();
          _wrapSelection('*', '*', fallback: tr.toolbar.placeholders.italicText);
        },
      ),
      ContextMenuButtonItem(
        label: 'Underline',
        onPressed: () {
          ContextMenuController.removeAny();
          _wrapSelection('<u>', '</u>');
        },
      ),
      ContextMenuButtonItem(
        label: 'Strike',
        onPressed: () {
          ContextMenuController.removeAny();
          _wrapSelection('~~', '~~');
        },
      ),
      ContextMenuButtonItem(
        label: 'Code',
        onPressed: () {
          ContextMenuController.removeAny();
          _wrapSelection('`', '`');
        },
      ),
      if (widget.actions.contains(TemplateToolbarAction.link))
        ContextMenuButtonItem(
          label: tr.toolbar.insert.link,
          onPressed: () {
            ContextMenuController.removeAny();
            _wrapSelection(
              '[',
              '](https://example.com)',
              fallback: tr.toolbar.placeholders.linkText,
            );
          },
        ),
      ...editableTextState.contextMenuButtonItems,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onTapOutside: (_) => _removeSlashOverlay(),
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        contextMenuBuilder: (context, editableTextState) {
          return AdaptiveTextSelectionToolbar.buttonItems(
            anchors: editableTextState.contextMenuAnchors,
            buttonItems: _contextMenuItems(context, editableTextState),
          );
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: scheme.surfaceContainerLowest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 1.2),
          ),
          hintText: widget.hintText,
          contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 48),
        ),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 15.5,
          height: 1.65,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

final class _SlashCommand {
  const _SlashCommand({
    required this.label,
    required this.keywords,
    required this.icon,
    required this.insertion,
    this.cursorBack = 0,
  });

  final String label;
  final List<String> keywords;
  final IconData icon;
  final String insertion;
  final int cursorBack;
}
