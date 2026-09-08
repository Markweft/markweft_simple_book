import 'dart:convert';
import 'dart:io';

import 'package:markweft_simple_book/features/book_library/data/extensions/chapter_management_repository_extensions.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final class ObsidianBookImportService {
  const ObsidianBookImportService();

  Future<MarkweftProject?> importVault({
    required Directory vault,
    required String title,
    required BookProjectRepository repository,
  }) async {
    if (!await vault.exists()) {
      throw StateError('The selected Obsidian folder does not exist.');
    }

    final markdownFiles = await _markdownFiles(vault);
    if (markdownFiles.isEmpty) {
      throw StateError('No Markdown files were found in the selected vault.');
    }

    final project = await repository.createProject(title: title);
    if (project == null) return null;

    final allFiles = await _allFiles(vault);
    final assetsByName = <String, File>{};
    for (final file in allFiles) {
      assetsByName.putIfAbsent(
        path.basename(file.path).toLowerCase(),
        () => file,
      );
    }

    final assetDataCache = <String, String>{};
    var chapters = await repository.loadChapters(project);
    if (chapters.isEmpty) {
      throw StateError('The new Markweft project has no initial chapter.');
    }

    var detectedRtl = false;
    for (var index = 0; index < markdownFiles.length; index++) {
      final file = markdownFiles[index];
      final raw = await file.readAsString();
      final parsed = _frontMatter(raw, fallbackTitle: path.basenameWithoutExtension(file.path));
      final transformed = await _transformMarkdown(
        parsed.body,
        noteFile: file,
        vault: vault,
        project: project,
        assetsByName: assetsByName,
        assetDataCache: assetDataCache,
      );
      detectedRtl = detectedRtl || _containsRtlScript(transformed);
      final chapterTitle = parsed.title.trim().isEmpty
          ? path.basenameWithoutExtension(file.path)
          : parsed.title.trim();
      final chapterMarkdown =
          '<!-- chapter: ${_safeDirective(chapterTitle)} -->\n\n$transformed';

      if (index == 0) {
        final renamed = await repository.renameChapter(
          project,
          chapters.first,
          title: chapterTitle,
        );
        await repository.saveChapterMarkdown(project, renamed, chapterMarkdown);
      } else {
        final chapter = await repository.createChapter(
          project,
          title: chapterTitle,
        );
        await repository.saveChapterMarkdown(project, chapter, chapterMarkdown);
      }
    }

    final existingSettings = await repository.loadBookSettings(project);
    await repository.saveBookSettings(
      project,
      existingSettings.copyWith(
        metadata: existingSettings.metadata.copyWith(title: title),
        languageCode: detectedRtl ? 'ar' : existingSettings.languageCode,
        direction: detectedRtl ? BookDirection.rtl : existingSettings.direction,
      ),
    );
    await repository.flushProject(project);
    return project;
  }

  Future<List<File>> _markdownFiles(Directory vault) async {
    final files = <File>[];
    await for (final entity in vault.list(recursive: true, followLinks: false)) {
      if (entity is! File || path.extension(entity.path).toLowerCase() != '.md') {
        continue;
      }
      final relative = path.relative(entity.path, from: vault.path);
      if (_isIgnored(relative)) continue;
      files.add(entity);
    }
    files.sort(
      (a, b) => path
          .relative(a.path, from: vault.path)
          .toLowerCase()
          .compareTo(path.relative(b.path, from: vault.path).toLowerCase()),
    );
    return files;
  }

  Future<List<File>> _allFiles(Directory vault) async {
    final files = <File>[];
    await for (final entity in vault.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = path.relative(entity.path, from: vault.path);
      if (_isIgnored(relative)) continue;
      files.add(entity);
    }
    return files;
  }

  bool _isIgnored(String relative) {
    final parts = path.split(relative);
    return parts.any(
      (part) => part == '.obsidian' || part == '.git' || part == '.trash',
    );
  }

  _FrontMatterResult _frontMatter(String source, {required String fallbackTitle}) {
    if (!source.startsWith('---\n') && !source.startsWith('---\r\n')) {
      return _FrontMatterResult(title: fallbackTitle, body: source);
    }

    final normalized = source.replaceAll('\r\n', '\n');
    final end = normalized.indexOf('\n---\n', 4);
    if (end < 0) return _FrontMatterResult(title: fallbackTitle, body: source);

    final yamlSource = normalized.substring(4, end);
    final body = normalized.substring(end + 5);
    try {
      final yaml = loadYaml(yamlSource);
      final rawTitle = yaml is YamlMap ? yaml['title']?.toString().trim() : null;
      return _FrontMatterResult(
        title: rawTitle == null || rawTitle.isEmpty ? fallbackTitle : rawTitle,
        body: body,
      );
    } on Object {
      return _FrontMatterResult(title: fallbackTitle, body: body);
    }
  }

  Future<String> _transformMarkdown(
    String source, {
    required File noteFile,
    required Directory vault,
    required MarkweftProject project,
    required Map<String, File> assetsByName,
    required Map<String, String> assetDataCache,
  }) async {
    var result = source;
    final embedPattern = RegExp(r'!\[\[([^\]|#]+)(?:\|[^\]]+)?\]\]');
    final matches = embedPattern.allMatches(result).toList().reversed;

    for (final match in matches) {
      final target = match.group(1)!.trim();
      final extension = path.extension(target).toLowerCase();
      if (!_isSupportedImage(extension)) continue;
      final asset = _resolveAsset(
        target,
        noteFile: noteFile,
        vault: vault,
        assetsByName: assetsByName,
      );
      if (asset == null) continue;
      final dataUri = await _importAsset(
        asset,
        project: project,
        cache: assetDataCache,
      );
      final alt = path.basenameWithoutExtension(target);
      result = result.replaceRange(
        match.start,
        match.end,
        '![$alt]($dataUri)',
      );
    }

    result = result.replaceAllMapped(
      RegExp(r'(?<!!)\[\[([^\]|#]+)(?:\|([^\]]+))?\]\]'),
      (match) {
        final target = match.group(1)!.trim();
        final alias = match.group(2)?.trim();
        return alias == null || alias.isEmpty
            ? path.basenameWithoutExtension(target)
            : alias;
      },
    );

    return result.trim();
  }

  File? _resolveAsset(
    String target, {
    required File noteFile,
    required Directory vault,
    required Map<String, File> assetsByName,
  }) {
    final local = File(path.normalize(path.join(noteFile.parent.path, target)));
    if (local.existsSync()) return local;
    final fromRoot = File(path.normalize(path.join(vault.path, target)));
    if (fromRoot.existsSync()) return fromRoot;
    return assetsByName[path.basename(target).toLowerCase()];
  }

  Future<String> _importAsset(
    File source, {
    required MarkweftProject project,
    required Map<String, String> cache,
  }) async {
    final normalizedSource = path.normalize(source.absolute.path);
    final cached = cache[normalizedSource];
    if (cached != null) return cached;

    await project.imagesDirectory.create(recursive: true);
    final extension = path.extension(source.path).toLowerCase();
    final stem = _safeStem(path.basenameWithoutExtension(source.path));
    var destination = File(path.join(project.imagesDirectory.path, '$stem$extension'));
    var attempt = 2;
    while (destination.existsSync()) {
      destination = File(
        path.join(project.imagesDirectory.path, '$stem-$attempt$extension'),
      );
      attempt++;
    }
    final bytes = await source.readAsBytes();
    await destination.writeAsBytes(bytes, flush: true);
    final mime = extension == '.png' ? 'image/png' : 'image/jpeg';
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    cache[normalizedSource] = dataUri;
    return dataUri;
  }

  bool _isSupportedImage(String extension) {
    return extension == '.png' || extension == '.jpg' || extension == '.jpeg';
  }

  bool _containsRtlScript(String text) {
    return RegExp(r'[\u0590-\u08FF\uFB1D-\uFDFF\uFE70-\uFEFF]')
        .hasMatch(text);
  }

  String _safeDirective(String value) => value.replaceAll('-->', '—').trim();

  String _safeStem(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^[-.]+|[-.]+$'), '');
    return normalized.isEmpty ? 'image' : normalized;
  }
}

final class _FrontMatterResult {
  const _FrontMatterResult({required this.title, required this.body});

  final String title;
  final String body;
}
