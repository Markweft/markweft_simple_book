import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:markweft_simple_book/features/book_library/data/mappers/book_settings_json.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final class MdwVersionConverter {
  const MdwVersionConverter();

  static const int currentVersion = 3;
  static const Set<int> supportedVersions = <int>{1, 3};

  static const XTypeGroup _projectType = XTypeGroup(
    label: 'Markweft book',
    extensions: <String>['mdw'],
  );

  static final RegExp _chapterDirective = RegExp(
    r'^\s*<!--\s*chapter\s*:\s*(.*?)\s*-->\s*$',
    caseSensitive: false,
  );

  Future<String?> pickAndConvert({required int targetVersion}) async {
    if (!supportedVersions.contains(targetVersion)) {
      throw ArgumentError.value(
        targetVersion,
        'targetVersion',
        'Supported MDW versions are 1 and 3.',
      );
    }

    final selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (selected == null) {
      return null;
    }

    final sourceFile = File(selected.path);
    final workspace = await _createWorkspace();

    try {
      await _extract(sourceFile, workspace);
      final sourceVersion = await _readVersion(workspace);

      if (!supportedVersions.contains(sourceVersion)) {
        throw FormatException(
          'MDW version $sourceVersion cannot be converted by this build. '
          'Supported source versions are 1 and 3.',
        );
      }

      if (sourceVersion != targetVersion) {
        switch (targetVersion) {
          case 1:
            await _convertToV1(workspace);
          case 3:
            await _convertToV3(workspace);
        }
      }

      final sourceName = path.basenameWithoutExtension(sourceFile.path);
      final location = await getSaveLocation(
        suggestedName: '${sourceName}_v$targetVersion',
        acceptedTypeGroups: const <XTypeGroup>[_projectType],
      );
      if (location == null) {
        return null;
      }

      final outputPath = _normalizeMdwPath(location.path);
      await _writeArchive(workspace, File(outputPath));
      return outputPath;
    } finally {
      if (await workspace.exists()) {
        await workspace.delete(recursive: true);
      }
    }
  }

  Future<int> inspectVersion(String projectPath) async {
    final workspace = await _createWorkspace();
    try {
      await _extract(File(projectPath), workspace);
      return _readVersion(workspace);
    } finally {
      if (await workspace.exists()) {
        await workspace.delete(recursive: true);
      }
    }
  }

  Future<void> _convertToV3(Directory workspace) async {
    final manifest = File(path.join(workspace.path, 'manifest.yaml'));
    final title = await _readTitle(manifest) ?? 'Untitled book';
    final legacyBook = File(
      path.join(workspace.path, 'content', 'book.md'),
    );
    final chaptersDirectory = Directory(
      path.join(workspace.path, 'content', 'chapters'),
    );
    final chapterIndex = File(path.join(chaptersDirectory.path, 'index.json'));

    await chaptersDirectory.create(recursive: true);

    if (await legacyBook.exists()) {
      final chapters = <Map<String, String>>[];
      IOSink? sink;
      var ordinal = 0;

      Future<void> startChapter(String chapterTitle) async {
        if (sink != null) {
          await sink!.flush();
          await sink!.close();
        }

        ordinal++;
        final id = 'chapter-${ordinal.toString().padLeft(4, '0')}';
        final fileName = '$id.md';
        chapters.add(<String, String>{
          'id': id,
          'title': chapterTitle,
          'file': fileName,
        });
        sink = File(path.join(chaptersDirectory.path, fileName)).openWrite();
        sink!.writeln('<!-- chapter: ${_safeDirectiveTitle(chapterTitle)} -->');
        sink!.writeln();
      }

      await for (final line in legacyBook
          .openRead()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        final match = _chapterDirective.firstMatch(line);
        if (match != null) {
          final chapterTitle = match.group(1)?.trim();
          await startChapter(
            chapterTitle == null || chapterTitle.isEmpty
                ? 'Chapter ${ordinal + 1}'
                : chapterTitle,
          );
          continue;
        }

        if (sink == null) {
          await startChapter(title);
        }
        sink!.writeln(line);
      }

      if (sink == null) {
        await startChapter(title);
      }
      await sink!.flush();
      await sink!.close();

      await chapterIndex.writeAsString(
        const JsonEncoder.withIndent('  ').convert(chapters),
        flush: true,
      );
      await legacyBook.delete();
    }

    final settingsFile = File(path.join(workspace.path, 'settings.json'));
    if (!await settingsFile.exists()) {
      await settingsFile.writeAsString(
        BookSettingsJson.encode(const BookSettings()),
        flush: true,
      );
    }

    await _writeManifestV3(workspace, title);
  }

  Future<void> _convertToV1(Directory workspace) async {
    final manifest = File(path.join(workspace.path, 'manifest.yaml'));
    final title = await _readTitle(manifest) ?? 'Untitled book';
    final chaptersDirectory = Directory(
      path.join(workspace.path, 'content', 'chapters'),
    );
    final chapterIndex = File(path.join(chaptersDirectory.path, 'index.json'));
    final legacyBook = File(path.join(workspace.path, 'content', 'book.md'));

    if (await chapterIndex.exists()) {
      final decoded = jsonDecode(await chapterIndex.readAsString());
      if (decoded is! List) {
        throw const FormatException('Invalid chapter index.');
      }

      final buffer = StringBuffer();
      for (var index = 0; index < decoded.length; index++) {
        final item = decoded[index];
        if (item is! Map) {
          throw const FormatException('Invalid chapter entry.');
        }

        final fileName = item['file']?.toString();
        if (fileName == null || fileName.isEmpty) {
          throw const FormatException('Chapter file name is missing.');
        }

        if (index > 0) {
          buffer.write('\n\n');
        }
        buffer.write(
          await File(path.join(chaptersDirectory.path, fileName)).readAsString(),
        );
      }

      await legacyBook.parent.create(recursive: true);
      await legacyBook.writeAsString(buffer.toString(), flush: true);
      await chaptersDirectory.delete(recursive: true);
    }

    final settingsFile = File(path.join(workspace.path, 'settings.json'));
    if (await settingsFile.exists()) {
      await settingsFile.delete();
    }

    final historyDirectory = Directory(path.join(workspace.path, 'history'));
    if (await historyDirectory.exists()) {
      await historyDirectory.delete(recursive: true);
    }

    await _writeManifestV1(workspace, title);
  }

  Future<void> _extract(File file, Directory workspace) async {
    if (!await file.exists()) {
      throw FileSystemException('Project file does not exist.', file.path);
    }

    final archive = ZipDecoder().decodeBytes(
      await file.readAsBytes(),
      verify: true,
    );

    for (final entry in archive) {
      final destination = _safeDestinationPath(workspace.path, entry.name);
      if (!entry.isFile) {
        await Directory(destination).create(recursive: true);
        continue;
      }

      final bytes = entry.readBytes();
      if (bytes == null) {
        throw FormatException('Unable to read ZIP entry: ${entry.name}');
      }

      final output = File(destination);
      await output.parent.create(recursive: true);
      await output.writeAsBytes(bytes, flush: true);
    }
  }

  Future<void> _writeArchive(Directory workspace, File output) async {
    final archive = Archive();

    await for (final entity in workspace.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      final relative = path
          .relative(entity.path, from: workspace.path)
          .replaceAll(path.separator, '/');
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }

    final encoded = ZipEncoder().encode(archive);
    await output.writeAsBytes(encoded, flush: true);
  }

  Future<int> _readVersion(Directory workspace) async {
    final manifest = File(path.join(workspace.path, 'manifest.yaml'));
    if (!await manifest.exists()) {
      throw const FormatException('Invalid .mdw project: manifest.yaml is missing.');
    }

    final document = loadYaml(await manifest.readAsString());
    if (document is! YamlMap) {
      throw const FormatException('Invalid manifest.yaml.');
    }

    final value = document['version'];
    final version = int.tryParse(value?.toString() ?? '');
    if (version == null) {
      throw const FormatException('The MDW format version is missing or invalid.');
    }
    return version;
  }

  Future<String?> _readTitle(File manifest) async {
    if (!await manifest.exists()) {
      return null;
    }

    final document = loadYaml(await manifest.readAsString());
    if (document is! YamlMap) {
      return null;
    }

    final value = document['title']?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _writeManifestV1(Directory workspace, String title) async {
    await File(path.join(workspace.path, 'manifest.yaml')).writeAsString(
      'format: markweft\n'
      'version: 1\n'
      'title: ${jsonEncode(title)}\n'
      'template:\n'
      '  id: markweft.simple\n'
      '  version: 0.1.0\n'
      'content: content/book.md\n'
      'assets: assets\n'
      'files: files\n',
      flush: true,
    );
  }

  Future<void> _writeManifestV3(Directory workspace, String title) async {
    await File(path.join(workspace.path, 'manifest.yaml')).writeAsString(
      'format: markweft\n'
      'version: 3\n'
      'title: ${jsonEncode(title)}\n'
      'template:\n'
      '  id: markweft.simple\n'
      '  version: 0.3.0\n'
      'settings: settings.json\n'
      'content: content/chapters/index.json\n'
      'assets: assets\n'
      'files: files\n',
      flush: true,
    );
  }

  Future<Directory> _createWorkspace() async {
    final root = Directory(
      path.join(Directory.systemTemp.path, 'markweft_version_conversion'),
    );
    await root.create(recursive: true);
    return root.createTemp('book_');
  }

  String _safeDestinationPath(String workspacePath, String archivePath) {
    final normalized = path.normalize(
      path.join(workspacePath, archivePath.replaceAll('/', path.separator)),
    );
    final root = path.normalize(workspacePath);

    if (normalized != root && !path.isWithin(root, normalized)) {
      throw FormatException('Unsafe file path inside .mdw: $archivePath');
    }
    return normalized;
  }

  String _normalizeMdwPath(String value) {
    final withoutRepeatedExtensions = value.replaceFirst(
      RegExp(r'(?:\.mdw)+$', caseSensitive: false),
      '',
    );
    return '$withoutRepeatedExtensions.mdw';
  }

  String _safeDirectiveTitle(String value) {
    return value.replaceAll('-->', '—').trim();
  }
}
