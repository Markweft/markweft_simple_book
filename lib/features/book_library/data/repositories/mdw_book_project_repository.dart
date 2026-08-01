import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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

  Future<MarkweftProject?> createProject({
    required String title,
  }) async {
    final location = await getSaveLocation(
      suggestedName: '${_safeFileName(title)}.mdw',
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (location == null) {
      return null;
    }

    final projectFile = File(_ensureMdwExtension(location.path));
    final workspace = await _createWorkspace();
    final project = MarkweftProject(
      file: projectFile,
      workspace: workspace,
      title: title.trim(),
    );

    await _initializeWorkspace(project);
    await saveProject(project);
    return project;
  }

  Future<MarkweftProject?> importMarkdown({
    required String title,
  }) async {
    final markdownFile = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_markdownType],
    );
    if (markdownFile == null) {
      return null;
    }

    final location = await getSaveLocation(
      suggestedName: '${_safeFileName(title)}.mdw',
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (location == null) {
      return null;
    }

    final workspace = await _createWorkspace();
    final project = MarkweftProject(
      file: File(_ensureMdwExtension(location.path)),
      workspace: workspace,
      title: title.trim(),
    );

    await _initializeWorkspace(
      project,
      markdown: await markdownFile.readAsString(),
    );
    await saveProject(project);
    return project;
  }

  Future<MarkweftProject?> pickAndOpenProject() async {
    final selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[_projectType],
    );
    if (selected == null) {
      return null;
    }

    return openProject(selected.path);
  }

  Future<MarkweftProject> openProject(String projectPath) async {
    final projectFile = File(projectPath);
    if (!await projectFile.exists()) {
      throw FileSystemException('Project file does not exist.', projectPath);
    }

    final workspace = await _createWorkspace();
    final archiveBytes = await projectFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(archiveBytes, verify: true);

    for (final entry in archive) {
      final destinationPath = _safeDestinationPath(
        workspace.path,
        entry.name,
      );

      if (entry.isFile) {
        final output = File(destinationPath);
        await output.parent.create(recursive: true);
        await output.writeAsBytes(
          _entryBytes(entry),
          flush: true,
        );
      } else {
        await Directory(destinationPath).create(recursive: true);
      }
    }

    final manifest = File(path.join(workspace.path, 'manifest.yaml'));
    final title = await _readTitle(manifest) ?? path.basenameWithoutExtension(
      projectFile.path,
    );

    final project = MarkweftProject(
      file: projectFile,
      workspace: workspace,
      title: title,
    );

    if (!await project.markdownFile.exists()) {
      throw const FormatException(
        'Invalid .mdw project: content/book.md is missing.',
      );
    }

    await project.imagesDirectory.create(recursive: true);
    await project.filesDirectory.create(recursive: true);
    return project;
  }

  Future<String> loadMarkdown(MarkweftProject project) {
    return project.markdownFile.readAsString();
  }

  Future<void> saveMarkdown(
    MarkweftProject project,
    String markdown,
  ) async {
    await project.markdownFile.parent.create(recursive: true);
    await project.markdownFile.writeAsString(markdown, flush: true);
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

    await project.file.parent.create(recursive: true);
    final temporaryFile = File('${project.file.path}.tmp');
    await temporaryFile.writeAsBytes(encoded, flush: true);

    if (await project.file.exists()) {
      await project.file.delete();
    }
    await temporaryFile.rename(project.file.path);
  }

  Future<void> closeProject(MarkweftProject project) async {
    if (await project.workspace.exists()) {
      await project.workspace.delete(recursive: true);
    }
  }

  Future<void> _initializeWorkspace(
    MarkweftProject project, {
    String markdown = _starterBook,
  }) async {
    await project.markdownFile.parent.create(recursive: true);
    await project.imagesDirectory.create(recursive: true);
    await project.filesDirectory.create(recursive: true);
    await File(path.join(project.imagesDirectory.path, '.keep')).writeAsString('');
    await File(path.join(project.filesDirectory.path, '.keep')).writeAsString('');
    await project.markdownFile.writeAsString(markdown, flush: true);

    final manifest = File(path.join(project.workspace.path, 'manifest.yaml'));
    await manifest.writeAsString(
      'format: markweft\n'
      'version: 1\n'
      'title: ${jsonEncode(project.title)}\n'
      'content: content/book.md\n'
      'assets: assets\n'
      'files: files\n',
      flush: true,
    );
  }

  Future<Directory> _createWorkspace() async {
    final temporaryDirectory = await getTemporaryDirectory();
    return temporaryDirectory.createTemp('markweft_');
  }

  Future<void> _appendDirectoryToArchive({
    required Archive archive,
    required Directory directory,
    required String rootPath,
  }) async {
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }

      final relativePath = path.relative(entity.path, from: rootPath);
      final archivePath = relativePath.replaceAll(path.separator, '/');
      final bytes = await entity.readAsBytes();
      archive.addFile(
        ArchiveFile(archivePath, bytes.length, bytes),
      );
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
    if (!await manifest.exists()) {
      return null;
    }

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

  String _ensureMdwExtension(String value) {
    return value.toLowerCase().endsWith('.mdw') ? value : '$value.mdw';
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

const String _starterBook = '''# New Markweft Book

Start writing your book here.

## First section

- Edit Markdown on the left
- Preview pages on the right
- Use `<!-- page -->` to start a new page

<!-- page -->

# Page Two

This is the second page.
''';
