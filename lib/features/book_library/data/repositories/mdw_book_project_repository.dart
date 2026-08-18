import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:markweft_simple_book/features/book_library/data/mappers/book_settings_json.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final class MdwBookProjectRepository implements BookProjectRepository {
  static const XTypeGroup _projectType = XTypeGroup(
    label: 'Markweft book',
    extensions: <String>['mdw'],
  );

  static const XTypeGroup _markdownType = XTypeGroup(
    label: 'Markdown',
    extensions: <String>['md', 'markdown'],
  );

  static final RegExp _chapterDirective = RegExp(
    r'^\s*<!--\s*chapter\s*:\s*(.*?)\s*-->\s*$',
    caseSensitive: false,
  );

  @override
  Future<MarkweftProject?> createProject({required String title}) async {
    final location = await getSaveLocation(
      suggestedName: _safeFileName(title),
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (location == null) return null;

    final project = MarkweftProject(
      file: File(_normalizeMdwPath(location.path)),
      workspace: await _createWorkspace(),
      title: title.trim(),
    );

    await _initializeWorkspace(project, markdown: _starterBook);
    await saveProject(project);
    return project;
  }

  @override
  Future<MarkweftProject?> importMarkdown({required String title}) async {
    final markdownFile = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_markdownType],
    );
    if (markdownFile == null) return null;

    final location = await getSaveLocation(
      suggestedName: _safeFileName(title),
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (location == null) return null;

    final project = MarkweftProject(
      file: File(_normalizeMdwPath(location.path)),
      workspace: await _createWorkspace(),
      title: title.trim(),
    );

    await _initializeWorkspace(project);
    await project.markdownFile.parent.create(recursive: true);
    await markdownFile.saveTo(project.markdownFile.path);
    await _ensureChapterStorage(project);
    await saveProject(project);
    return project;
  }

  @override
  Future<MarkweftProject?> pickAndOpenProject() async {
    final selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    return selected == null ? null : openProject(selected.path);
  }

  @override
  Future<MarkweftProject> openProject(String projectPath) async {
    final projectFile = File(projectPath);
    if (!await projectFile.exists()) {
      throw FileSystemException('Project file does not exist.', projectPath);
    }

    final workspace = await _createWorkspace();

    try {
      final archive = ZipDecoder().decodeBytes(
        await projectFile.readAsBytes(),
        verify: true,
      );

      for (final entry in archive) {
        final destinationPath = _safeDestinationPath(
          workspace.path,
          entry.name,
        );

        if (entry.isFile) {
          final output = File(destinationPath);
          await output.parent.create(recursive: true);
          await output.writeAsBytes(_entryBytes(entry), flush: true);
        } else {
          await Directory(destinationPath).create(recursive: true);
        }
      }

      final manifest = File(path.join(workspace.path, 'manifest.yaml'));
      final title = await _readTitle(manifest) ??
          path.basenameWithoutExtension(projectFile.path);

      final project = MarkweftProject(
        file: projectFile,
        workspace: workspace,
        title: title,
      );

      final hasLegacyBook = await project.markdownFile.exists();
      final hasChapterIndex = await project.chaptersIndexFile.exists();
      if (!hasLegacyBook && !hasChapterIndex) {
        throw const FormatException(
          'Invalid .mdw project: chapter content is missing.',
        );
      }

      await project.imagesDirectory.create(recursive: true);
      await project.filesDirectory.create(recursive: true);
      if (!await project.settingsFile.exists()) {
        await project.settingsFile.writeAsString(
          BookSettingsJson.encode(const BookSettings()),
          flush: true,
        );
      }

      final migrated = await _ensureChapterStorage(project);
      if (migrated) await saveProject(project);
      return project;
    } on Object {
      if (await workspace.exists()) {
        await workspace.delete(recursive: true);
      }
      rethrow;
    }
  }

  @override
  Future<List<BookChapterFile>> loadChapters(MarkweftProject project) async {
    await _ensureChapterStorage(project);
    return _readChapterIndex(project);
  }

  @override
  Future<BookChapterFile> createChapter(
    MarkweftProject project, {
    required String title,
  }) async {
    final chapters = await loadChapters(project);
    final normalizedTitle = title.trim().isEmpty ? 'Untitled chapter' : title.trim();
    final id = 'chapter-${DateTime.now().microsecondsSinceEpoch}';
    final chapter = BookChapterFile(
      id: id,
      title: normalizedTitle,
      fileName: '$id.md',
    );

    await project.chapterFile(chapter.fileName).writeAsString(
      '<!-- chapter: ${_safeDirectiveTitle(normalizedTitle)} -->\n\n'
      '# $normalizedTitle\n\n',
      flush: true,
    );
    await _writeChapterIndex(project, <BookChapterFile>[...chapters, chapter]);
    await saveProject(project);
    return chapter;
  }

  @override
  Future<String> loadChapterMarkdown(
    MarkweftProject project,
    BookChapterFile chapter,
  ) {
    return project.chapterFile(chapter.fileName).readAsString();
  }

  @override
  Future<void> saveChapterMarkdown(
    MarkweftProject project,
    BookChapterFile chapter,
    String markdown,
  ) async {
    final file = project.chapterFile(chapter.fileName);
    await file.parent.create(recursive: true);
    await file.writeAsString(markdown, flush: true);
  }

  @override
  Future<String> loadWholeBookMarkdown(MarkweftProject project) async {
    final chapters = await loadChapters(project);
    final buffer = StringBuffer();

    for (var index = 0; index < chapters.length; index++) {
      if (index > 0) buffer.write('\n\n');
      buffer.write(await loadChapterMarkdown(project, chapters[index]));
    }

    return buffer.toString();
  }

  @override
  Future<void> flushProject(MarkweftProject project) => saveProject(project);

  @override
  Future<String> loadMarkdown(MarkweftProject project) {
    return loadWholeBookMarkdown(project);
  }

  @override
  Future<void> saveMarkdown(
    MarkweftProject project,
    String markdown,
  ) async {
    await project.markdownFile.parent.create(recursive: true);
    await project.markdownFile.writeAsString(markdown, flush: true);
    if (await project.chaptersDirectory.exists()) {
      await project.chaptersDirectory.delete(recursive: true);
    }
    await _ensureChapterStorage(project);
    await saveProject(project);
  }

  @override
  Future<BookSettings> loadBookSettings(MarkweftProject project) async {
    if (!await project.settingsFile.exists()) {
      return const BookSettings();
    }

    try {
      return BookSettingsJson.decode(await project.settingsFile.readAsString());
    } on FormatException {
      return const BookSettings();
    }
  }

  @override
  Future<void> saveBookSettings(
    MarkweftProject project,
    BookSettings settings,
  ) async {
    await project.settingsFile.writeAsString(
      BookSettingsJson.encode(settings),
      flush: true,
    );
    await saveProject(project);
  }

  Future<void> saveProject(MarkweftProject project) async {
    final archive = Archive();
    await _appendDirectoryToArchive(
      archive: archive,
      directory: project.workspace,
      rootPath: project.workspace.path,
    );

    final encoded = ZipEncoder().encode(archive);
    await project.file.writeAsBytes(encoded, flush: true);
  }

  @override
  Future<void> closeProject(MarkweftProject project) async {
    await saveProject(project);
    if (await project.workspace.exists()) {
      await project.workspace.delete(recursive: true);
    }
  }

  Future<void> _initializeWorkspace(
    MarkweftProject project, {
    String? markdown,
  }) async {
    await project.chaptersDirectory.create(recursive: true);
    await project.imagesDirectory.create(recursive: true);
    await project.filesDirectory.create(recursive: true);

    await File(path.join(project.imagesDirectory.path, '.keep')).writeAsString('');
    await File(path.join(project.filesDirectory.path, '.keep')).writeAsString('');
    await project.settingsFile.writeAsString(
      BookSettingsJson.encode(const BookSettings()),
      flush: true,
    );

    if (markdown != null) {
      await project.markdownFile.parent.create(recursive: true);
      await project.markdownFile.writeAsString(markdown, flush: true);
      await _ensureChapterStorage(project);
    } else {
      await _writeChapterIndex(project, const <BookChapterFile>[]);
    }

    await File(path.join(project.workspace.path, 'manifest.yaml')).writeAsString(
      'format: markweft\n'
      'version: 3\n'
      'title: ${jsonEncode(project.title)}\n'
      'template:\n'
      '  id: markweft.simple\n'
      '  version: 0.2.0\n'
      'settings: settings.json\n'
      'content: content/chapters/index.json\n'
      'assets: assets\n'
      'files: files\n',
      flush: true,
    );
  }

  Future<bool> _ensureChapterStorage(MarkweftProject project) async {
    final hasLegacyBook = await project.markdownFile.exists();
    if (await project.chaptersIndexFile.exists()) {
      final existing = await _readChapterIndex(project);
      if (existing.isNotEmpty || !hasLegacyBook) return false;
      await project.chaptersIndexFile.delete();
    }

    await project.chaptersDirectory.create(recursive: true);
    if (!hasLegacyBook) {
      await _writeChapterIndex(project, const <BookChapterFile>[]);
      return true;
    }

    final chapters = <BookChapterFile>[];
    IOSink? sink;
    var ordinal = 0;

    Future<void> startChapter(String title) async {
      if (sink != null) {
        await sink!.flush();
        await sink!.close();
      }

      ordinal++;
      final id = 'chapter-${ordinal.toString().padLeft(4, '0')}';
      final chapter = BookChapterFile(
        id: id,
        title: title,
        fileName: '$id.md',
      );
      chapters.add(chapter);
      sink = project.chapterFile(chapter.fileName).openWrite();
      sink!.writeln('<!-- chapter: ${_safeDirectiveTitle(title)} -->');
      sink!.writeln();
    }

    await for (final line in project.markdownFile
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final match = _chapterDirective.firstMatch(line);
      if (match != null) {
        final title = match.group(1)?.trim();
        await startChapter(
          title == null || title.isEmpty ? 'Chapter ${ordinal + 1}' : title,
        );
        continue;
      }

      if (sink == null) await startChapter(project.title);
      sink!.writeln(line);
    }

    if (sink == null) await startChapter(project.title);
    await sink!.flush();
    await sink!.close();
    await _writeChapterIndex(project, chapters);
    await project.markdownFile.delete();
    return true;
  }

  Future<List<BookChapterFile>> _readChapterIndex(
    MarkweftProject project,
  ) async {
    final decoded = jsonDecode(await project.chaptersIndexFile.readAsString());
    if (decoded is! List) {
      throw const FormatException('Chapter index must be a JSON array.');
    }

    return List<BookChapterFile>.unmodifiable(
      decoded.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid chapter entry.');
        }
        return BookChapterFile(
          id: item['id']?.toString() ?? '',
          title: item['title']?.toString() ?? 'Untitled chapter',
          fileName: item['file']?.toString() ?? '',
        );
      }),
    );
  }

  Future<void> _writeChapterIndex(
    MarkweftProject project,
    List<BookChapterFile> chapters,
  ) async {
    await project.chaptersDirectory.create(recursive: true);
    await project.chaptersIndexFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert([
        for (final chapter in chapters)
          <String, String>{
            'id': chapter.id,
            'title': chapter.title,
            'file': chapter.fileName,
          },
      ]),
      flush: true,
    );
  }

  Future<Directory> _createWorkspace() async {
    final root = Directory(path.join(Directory.systemTemp.path, 'markweft_workspaces'));
    await root.create(recursive: true);
    return root.createTemp('book_');
  }

  Future<void> _appendDirectoryToArchive({
    required Archive archive,
    required Directory directory,
    required String rootPath,
  }) async {
    await for (final entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;

      final relativePath = path.relative(entity.path, from: rootPath);
      final archivePath = relativePath.replaceAll(path.separator, '/');
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
    }
  }

  Uint8List _entryBytes(ArchiveFile entry) {
    final bytes = entry.readBytes();
    if (bytes == null) {
      throw FormatException('Unable to read ZIP entry: ${entry.name}');
    }
    return bytes;
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

  Future<String?> _readTitle(File manifest) async {
    if (!await manifest.exists()) return null;

    try {
      final document = loadYaml(await manifest.readAsString());
      if (document is YamlMap) {
        final value = document['title']?.toString().trim();
        return value == null || value.isEmpty ? null : value;
      }
    } on Object {
      return null;
    }
    return null;
  }

  String _safeDirectiveTitle(String value) => value.replaceAll('-->', '—').trim();

  String _normalizeMdwPath(String value) {
    final withoutRepeatedExtensions = value.replaceFirst(
      RegExp(r'(?:\.mdw)+$', caseSensitive: false),
      '',
    );
    return '$withoutRepeatedExtensions.mdw';
  }

  String _safeFileName(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return normalized.isEmpty ? 'untitled_book' : normalized;
  }
}

const String _starterBook = '''<!-- chapter: Chapter One -->

# New Markweft Book

Start writing your book here.

## First section

- Edit only the active chapter in the Markdown editor
- Each chapter is stored as its own Markdown file
- Preview renders only the active chapter while editing
- Full-book parsing happens only for export
''';
