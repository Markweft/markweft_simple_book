import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:markweft_simple_book/features/book_history/domain/entities/book_version.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';

final class BookHistoryService {
  const BookHistoryService();

  static const Duration recoveryInterval = Duration(minutes: 10);

  Future<BookVersion?> createSnapshotIfChanged({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required String reason,
    String message = '',
    bool enforceRecoveryInterval = false,
  }) async {
    await project.historyObjectsDirectory.create(recursive: true);
    await project.historyCommitsDirectory.create(recursive: true);

    final chapters = await repository.loadChapters(project);
    final versionChapters = <BookVersionChapter>[];
    final stateParts = <String>[];

    final settingsText = await project.settingsFile.readAsString();
    final settingsObject = await _storeObject(project, settingsText);
    stateParts.add('settings:$settingsObject');

    for (final chapter in chapters) {
      final markdown = await repository.loadChapterMarkdown(project, chapter);
      final object = await _storeObject(project, markdown);
      versionChapters.add(
        BookVersionChapter(
          id: chapter.id,
          title: chapter.title,
          fileName: chapter.fileName,
          object: object,
        ),
      );
      stateParts.add('${chapter.id}:${chapter.title}:${chapter.fileName}:$object');
    }

    final stateHash = sha256.convert(utf8.encode(stateParts.join('|'))).toString();
    final latest = await latestVersion(project);
    if (latest?.stateHash == stateHash) {
      return null;
    }

    if (enforceRecoveryInterval && latest != null) {
      final elapsed = DateTime.now().difference(latest.createdAt);
      if (elapsed < recoveryInterval) {
        return null;
      }
    }

    final now = DateTime.now().toUtc();
    final id = '${now.microsecondsSinceEpoch}';
    final version = BookVersion(
      id: id,
      createdAt: now,
      reason: reason,
      message: message,
      stateHash: stateHash,
      settingsObject: settingsObject,
      chapters: List<BookVersionChapter>.unmodifiable(versionChapters),
    );

    await _commitFile(project, id).writeAsString(
      const JsonEncoder.withIndent('  ').convert(_toJson(version)),
      flush: true,
    );
    return version;
  }

  Future<List<BookVersion>> versions(MarkweftProject project) async {
    if (!await project.historyCommitsDirectory.exists()) {
      return const <BookVersion>[];
    }

    final files = await project.historyCommitsDirectory
        .list(followLinks: false)
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));

    final versions = <BookVersion>[];
    for (final file in files) {
      try {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map<String, dynamic>) {
          versions.add(_fromJson(decoded));
        }
      } on Object {
        // Keep history browsing resilient if one commit file is damaged.
      }
    }
    return List<BookVersion>.unmodifiable(versions);
  }

  Future<BookVersion?> latestVersion(MarkweftProject project) async {
    final all = await versions(project);
    return all.isEmpty ? null : all.first;
  }

  Future<void> restore({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required BookVersion version,
  }) async {
    await createSnapshotIfChanged(
      project: project,
      repository: repository,
      reason: 'beforeRestore',
      message: 'Automatic checkpoint before restoring ${version.id}',
    );

    await project.chaptersDirectory.create(recursive: true);
    await for (final entity in project.chaptersDirectory.list(followLinks: false)) {
      if (entity is File && entity.path.endsWith('.md')) {
        await entity.delete();
      }
    }

    final settings = await _readObject(project, version.settingsObject);
    await project.settingsFile.writeAsString(settings, flush: true);

    final chapterIndex = <Map<String, String>>[];
    for (final chapter in version.chapters) {
      final markdown = await _readObject(project, chapter.object);
      await project.chapterFile(chapter.fileName).writeAsString(markdown, flush: true);
      chapterIndex.add(<String, String>{
        'id': chapter.id,
        'title': chapter.title,
        'file': chapter.fileName,
      });
    }

    await project.chaptersIndexFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(chapterIndex),
      flush: true,
    );
    await repository.flushProject(project);
  }

  Future<void> deleteVersion(
    MarkweftProject project,
    BookVersion version,
  ) async {
    final file = _commitFile(project, version.id);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> pruneRecoveryVersions(
    MarkweftProject project, {
    int keepLatest = 30,
  }) async {
    final all = await versions(project);
    final recovery = all.where((version) => version.reason == 'recovery').toList();
    if (recovery.length <= keepLatest) {
      return;
    }

    for (final version in recovery.skip(keepLatest)) {
      await deleteVersion(project, version);
    }
  }

  Future<String> _storeObject(MarkweftProject project, String content) async {
    final hash = sha256.convert(utf8.encode(content)).toString();
    final file = File(
      '${project.historyObjectsDirectory.path}${Platform.pathSeparator}$hash',
    );
    if (!await file.exists()) {
      await file.writeAsString(content, flush: true);
    }
    return hash;
  }

  Future<String> _readObject(MarkweftProject project, String hash) {
    return File(
      '${project.historyObjectsDirectory.path}${Platform.pathSeparator}$hash',
    ).readAsString();
  }

  File _commitFile(MarkweftProject project, String id) => File(
        '${project.historyCommitsDirectory.path}${Platform.pathSeparator}$id.json',
      );

  Map<String, Object?> _toJson(BookVersion version) => <String, Object?>{
        'id': version.id,
        'createdAt': version.createdAt.toIso8601String(),
        'reason': version.reason,
        'message': version.message,
        'stateHash': version.stateHash,
        'settingsObject': version.settingsObject,
        'chapters': [
          for (final chapter in version.chapters)
            <String, String>{
              'id': chapter.id,
              'title': chapter.title,
              'file': chapter.fileName,
              'object': chapter.object,
            },
        ],
      };

  BookVersion _fromJson(Map<String, dynamic> json) {
    final chaptersRaw = json['chapters'];
    final chapters = <BookVersionChapter>[];
    if (chaptersRaw is List) {
      for (final item in chaptersRaw) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        chapters.add(
          BookVersionChapter(
            id: item['id']?.toString() ?? '',
            title: item['title']?.toString() ?? 'Untitled chapter',
            fileName: item['file']?.toString() ?? '',
            object: item['object']?.toString() ?? '',
          ),
        );
      }
    }

    return BookVersion(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      reason: json['reason']?.toString() ?? 'manual',
      message: json['message']?.toString() ?? '',
      stateHash: json['stateHash']?.toString() ?? '',
      settingsObject: json['settingsObject']?.toString() ?? '',
      chapters: List<BookVersionChapter>.unmodifiable(chapters),
    );
  }
}
