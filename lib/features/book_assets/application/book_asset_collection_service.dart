import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:path/path.dart' as path;

final class BookAssetItem {
  const BookAssetItem({
    required this.file,
    required this.relativePath,
    required this.mimeType,
  });

  final File file;
  final String relativePath;
  final String mimeType;

  String get name => path.basename(file.path);

  Future<String> dataUri() async {
    final bytes = await file.readAsBytes();
    return 'data:$mimeType;base64,${base64Encode(bytes)}';
  }

  Future<String> markdown({String? alt}) async {
    final data = await dataUri();
    final label = (alt == null || alt.trim().isEmpty)
        ? path.basenameWithoutExtension(name)
        : alt.trim();
    return '![$label]($data)';
  }
}

final class BookAssetCollectionService {
  const BookAssetCollectionService();

  static const Set<String> supportedExtensions = <String>{
    '.png',
    '.jpg',
    '.jpeg',
  };

  Future<List<BookAssetItem>> list(MarkweftProject project) async {
    final directory = project.imagesDirectory;
    if (!await directory.exists()) return const <BookAssetItem>[];

    final items = <BookAssetItem>[];
    await for (final entity in directory.list(followLinks: false)) {
      if (entity is! File) continue;
      final extension = path.extension(entity.path).toLowerCase();
      if (!supportedExtensions.contains(extension)) continue;
      items.add(_item(entity));
    }
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List<BookAssetItem>.unmodifiable(items);
  }

  Future<List<BookAssetItem>> importImages(
    MarkweftProject project,
    BookProjectRepository repository,
    List<XFile> selected,
  ) async {
    await project.imagesDirectory.create(recursive: true);
    final imported = <BookAssetItem>[];

    for (final source in selected) {
      final extension = path.extension(source.path).toLowerCase();
      if (!supportedExtensions.contains(extension)) continue;
      final safeStem = _safeStem(path.basenameWithoutExtension(source.path));
      final destination = await _uniqueDestination(
        project.imagesDirectory,
        safeStem,
        extension,
      );
      final bytes = await source.readAsBytes();
      await destination.writeAsBytes(bytes, flush: true);
      imported.add(_item(destination));
    }

    if (imported.isNotEmpty) await repository.flushProject(project);
    return List<BookAssetItem>.unmodifiable(imported);
  }

  Future<void> delete(
    MarkweftProject project,
    BookProjectRepository repository,
    BookAssetItem asset,
  ) async {
    final root = path.normalize(project.imagesDirectory.absolute.path);
    final target = path.normalize(asset.file.absolute.path);
    if (!path.isWithin(root, target)) {
      throw StateError('Asset is outside this book project.');
    }
    if (await asset.file.exists()) await asset.file.delete();
    await repository.flushProject(project);
  }

  BookAssetItem _item(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return BookAssetItem(
      file: file,
      relativePath: 'assets/images/${path.basename(file.path)}',
      mimeType: extension == '.png' ? 'image/png' : 'image/jpeg',
    );
  }

  Future<File> _uniqueDestination(
    Directory directory,
    String stem,
    String extension,
  ) async {
    var attempt = 1;
    while (true) {
      final suffix = attempt == 1 ? '' : '-$attempt';
      final file = File(path.join(directory.path, '$stem$suffix$extension'));
      if (!await file.exists()) return file;
      attempt++;
    }
  }

  String _safeStem(String source) {
    final value = source
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '');
    return value.isEmpty ? 'image' : value;
  }
}
