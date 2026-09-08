import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:markweft_simple_book/features/book_assets/application/book_asset_collection_service.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';

final class BookAssetCollectionDialog extends StatefulWidget {
  const BookAssetCollectionDialog({
    required this.project,
    required this.repository,
    super.key,
  });

  final MarkweftProject project;
  final BookProjectRepository repository;

  @override
  State<BookAssetCollectionDialog> createState() =>
      _BookAssetCollectionDialogState();
}

final class _BookAssetCollectionDialogState
    extends State<BookAssetCollectionDialog> {
  static const BookAssetCollectionService _service =
      BookAssetCollectionService();
  List<BookAssetItem> _assets = const <BookAssetItem>[];
  bool _busy = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final assets = await _service.list(widget.project);
      if (!mounted) return;
      setState(() => _assets = assets);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    const type = XTypeGroup(
      label: 'Book images',
      extensions: <String>['png', 'jpg', 'jpeg'],
    );
    final selected = await openFiles(
      acceptedTypeGroups: const <XTypeGroup>[type],
    );
    if (selected.isEmpty) return;

    setState(() => _busy = true);
    try {
      await _service.importImages(
        widget.project,
        widget.repository,
        selected,
      );
      await _reload();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _busy = false;
      });
    }
  }

  Future<void> _use(BookAssetItem asset) async {
    setState(() => _busy = true);
    try {
      final markdown = await asset.markdown();
      if (!mounted) return;
      Navigator.of(context).pop(markdown);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _busy = false;
      });
    }
  }

  Future<void> _delete(BookAssetItem asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete asset?'),
        content: Text(asset.name),
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
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _service.delete(widget.project, widget.repository, asset);
      await _reload();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Book asset collection'),
      content: SizedBox(
        width: 760,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Images are stored inside this .mdw book. Choose an asset to copy an embeddable Markdown image into the editor.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _busy ? null : _import,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: const Text('Import images'),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text('$_error'),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: _busy && _assets.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _assets.isEmpty
                      ? const Center(
                          child: Text('No images in this book yet.'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 190,
                            mainAxisExtent: 190,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _assets.length,
                          itemBuilder: (context, index) {
                            final asset = _assets[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: _busy ? null : () => _use(asset),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Image.file(
                                        asset.file,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Center(
                                          child: Icon(Icons.broken_image_outlined),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                        10,
                                        7,
                                        4,
                                        6,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              asset.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            tooltip: 'Delete',
                                            visualDensity: VisualDensity.compact,
                                            onPressed: _busy
                                                ? null
                                                : () => _delete(asset),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
