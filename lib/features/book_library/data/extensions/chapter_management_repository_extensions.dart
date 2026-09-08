import 'dart:convert';

import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';

extension ChapterManagementRepositoryExtensions on BookProjectRepository {
  Future<BookChapterFile> renameChapter(
    MarkweftProject project,
    BookChapterFile chapter, {
    required String title,
  }) async {
    final normalizedTitle = title.trim().isEmpty ? 'Untitled chapter' : title.trim();
    final chapters = await loadChapters(project);
    final updated = chapter.copyWith(title: normalizedTitle);
    final updatedChapters = [
      for (final item in chapters)
        if (item.id == chapter.id) updated else item,
    ];

    final markdown = await loadChapterMarkdown(project, chapter);
    final lines = const LineSplitter().convert(markdown);
    final directive = '<!-- chapter: ${_safeDirectiveTitle(normalizedTitle)} -->';
    final nextMarkdown = lines.isNotEmpty &&
            RegExp(r'^\s*<!--\s*chapter\s*:', caseSensitive: false)
                .hasMatch(lines.first)
        ? <String>[directive, ...lines.skip(1)].join('\n')
        : '$directive\n\n$markdown';

    await saveChapterMarkdown(project, updated, nextMarkdown);
    await _writeIndex(project, updatedChapters);
    await flushProject(project);
    return updated;
  }

  Future<List<BookChapterFile>> deleteChapterTree(
    MarkweftProject project,
    BookChapterFile chapter,
  ) async {
    final chapters = await loadChapters(project);
    final idsToDelete = <String>{chapter.id};

    var changed = true;
    while (changed) {
      changed = false;
      for (final item in chapters) {
        if (item.parentId != null &&
            idsToDelete.contains(item.parentId) &&
            idsToDelete.add(item.id)) {
          changed = true;
        }
      }
    }

    final remaining = chapters
        .where((item) => !idsToDelete.contains(item.id))
        .toList(growable: false);
    if (remaining.isEmpty) {
      throw StateError('A book must contain at least one chapter.');
    }

    final deleted = chapters
        .where((item) => idsToDelete.contains(item.id))
        .toList(growable: false);
    for (final item in deleted) {
      final file = project.chapterFile(item.fileName);
      if (await file.exists()) await file.delete();
    }

    await _writeIndex(project, remaining);
    await flushProject(project);
    return deleted;
  }

  Future<void> deleteChapter(
    MarkweftProject project,
    BookChapterFile chapter,
  ) async {
    await deleteChapterTree(project, chapter);
  }

  Future<void> reorderChapters(
    MarkweftProject project,
    List<BookChapterFile> chapters,
  ) async {
    await _writeIndex(project, chapters);
    await flushProject(project);
  }

  Future<void> _writeIndex(
    MarkweftProject project,
    List<BookChapterFile> chapters,
  ) async {
    await project.chaptersDirectory.create(recursive: true);
    await project.chaptersIndexFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert([
        for (final chapter in chapters)
          <String, Object?>{
            'id': chapter.id,
            'title': chapter.title,
            'file': chapter.fileName,
            'parentId': chapter.parentId,
          },
      ]),
      flush: true,
    );
  }

  String _safeDirectiveTitle(String value) => value.replaceAll('-->', '—').trim();
}
