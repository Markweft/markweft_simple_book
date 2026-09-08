import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/features/book_history/data/services/book_history_service.dart';
import 'package:markweft_simple_book/features/book_history/domain/entities/book_version.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';

final class BookHistoryPage extends StatefulWidget {
  const BookHistoryPage({
    required this.project,
    required this.repository,
    super.key,
  });

  final MarkweftProject project;
  final BookProjectRepository repository;

  @override
  State<BookHistoryPage> createState() => _BookHistoryPageState();
}

final class _BookHistoryPageState extends State<BookHistoryPage> {
  static const BookHistoryService _historyService = BookHistoryService();

  List<BookVersion> _versions = const <BookVersion>[];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final versions = await _historyService.versions(widget.project);
      if (!mounted) return;
      setState(() => _versions = versions);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createManualVersion() async {
    final controller = TextEditingController();
    final tr = Translations.of(context);
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.history.create.title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: tr.history.create.descriptionLabel,
            hintText: tr.history.create.descriptionHint,
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr.app.actions.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(tr.dialogs.bookTitle.create.action),
          ),
        ],
      ),
    );
    controller.dispose();
    if (message == null || !mounted) return;

    await _runBusy(() async {
      await _historyService.createSnapshotIfChanged(
        project: widget.project,
        repository: widget.repository,
        reason: 'manual',
        message: message.isEmpty ? tr.history.create.manualVersion : message,
      );
      await widget.repository.flushProject(widget.project);
      await _load();
    });
  }

  Future<void> _restore(BookVersion version) async {
    final tr = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr.history.restore.question),
        content: Text(
          tr.history.restore.description(date: _formatDate(version.createdAt)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr.app.actions.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(tr.history.restore.action),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runBusy(() async {
      await _historyService.restore(
        project: widget.project,
        repository: widget.repository,
        version: version,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    });
  }

  Future<void> _delete(BookVersion version) async {
    final tr = Translations.of(context);
    if (version.isManual) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(tr.history.delete.question),
          content: Text(tr.history.delete.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr.app.actions.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr.history.delete.action),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await _runBusy(() async {
      await _historyService.deleteVersion(widget.project, version);
      await widget.repository.flushProject(widget.project);
      await _load();
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.history.page.title),
        actions: [
          FilledButton.icon(
            onPressed: _busy ? null : _createManualVersion,
            icon: const Icon(Icons.add),
            label: Text(tr.history.create.title),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: _load,
                  child: Text(tr.app.actions.retry),
                ),
              ],
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _versions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            tr.history.page.empty,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _versions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final version = _versions[index];
                          final chapters = tr.history.metadata.chapters(
                            count: version.chapters.length,
                          );
                          return ListTile(
                            leading: Icon(
                              version.isManual
                                  ? Icons.bookmark_outline
                                  : Icons.history,
                            ),
                            title: Text(
                              version.message.isEmpty
                                  ? _reasonLabel(version.reason, tr)
                                  : version.message,
                            ),
                            subtitle: Text(
                              tr.history.metadata.summary(
                                date: _formatDate(version.createdAt),
                                chapters: chapters,
                                reason: _reasonLabel(version.reason, tr),
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                              enabled: !_busy,
                              onSelected: (value) {
                                if (value == 'restore') {
                                  _restore(version);
                                } else if (value == 'delete') {
                                  _delete(version);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'restore',
                                  child: Text(tr.history.restore.action),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(tr.history.delete.action),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final locale = TranslationProvider.of(context).flutterLocale.toLanguageTag();
    return DateFormat.yMd(locale).add_Hm().format(value.toLocal());
  }

  String _reasonLabel(String reason, Translations tr) => switch (reason) {
        'manual' => tr.history.reasons.manual,
        'recovery' => tr.history.reasons.recovery,
        'beforeDelete' => tr.history.reasons.beforeDelete,
        'beforeRestore' => tr.history.reasons.beforeRestore,
        'settingsChanged' => tr.history.reasons.settingsChanged,
        _ => reason,
      };
}
