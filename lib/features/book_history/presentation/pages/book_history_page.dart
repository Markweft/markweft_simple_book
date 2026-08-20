import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create version'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Before rewriting chapter 4',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create'),
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
        message: message.isEmpty ? 'Manual version' : message,
      );
      await widget.repository.flushProject(widget.project);
      await _load();
    });
  }

  Future<void> _restore(BookVersion version) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore this version?'),
        content: Text(
          'The current book state will be saved automatically before restoring '
          '${_formatDate(version.createdAt)}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
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
    if (version.isManual) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete manual version?'),
          content: const Text('This removes the checkpoint from the history list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Version history'),
        actions: [
          FilledButton.icon(
            onPressed: _busy ? null : _createManualVersion,
            icon: const Icon(Icons.add),
            label: const Text('Create version'),
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
                TextButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _versions.isEmpty
                    ? const Center(
                        child: Text(
                          'No versions yet. Create a manual version or keep editing; '
                          'recovery checkpoints are created automatically.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _versions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final version = _versions[index];
                          return ListTile(
                            leading: Icon(
                              version.isManual
                                  ? Icons.bookmark_outline
                                  : Icons.history,
                            ),
                            title: Text(
                              version.message.isEmpty
                                  ? _reasonLabel(version.reason)
                                  : version.message,
                            ),
                            subtitle: Text(
                              '${_formatDate(version.createdAt)} · '
                              '${version.chapters.length} chapters · '
                              '${_reasonLabel(version.reason)}',
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
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'restore',
                                  child: Text('Restore'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
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
    return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
  }

  String _reasonLabel(String reason) => switch (reason) {
        'manual' => 'Manual',
        'recovery' => 'Recovery',
        'beforeDelete' => 'Before delete',
        'beforeRestore' => 'Before restore',
        'settingsChanged' => 'Settings changed',
        _ => reason,
      };
}
