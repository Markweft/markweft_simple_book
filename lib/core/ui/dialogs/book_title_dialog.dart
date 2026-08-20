import 'package:flutter/material.dart';
import 'package:markweft_simple_book/i18n/strings.g.dart';

final class BookTitleDialog extends StatefulWidget {
  const BookTitleDialog({
    required this.title,
    required this.actionLabel,
    super.key,
  });

  final String title;
  final String actionLabel;

  @override
  State<BookTitleDialog> createState() => _BookTitleDialogState();
}

final class _BookTitleDialogState extends State<BookTitleDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final normalizedTitle = _controller.text.trim();

    if (normalizedTitle.isEmpty) {
      return;
    }

    Navigator.of(context).pop(normalizedTitle);
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: tr.dialogs.bookTitle,
          hintText: tr.dialogs.bookTitleHint,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr.app.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
