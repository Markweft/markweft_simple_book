import 'dart:typed_data';

import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookExportService {
  const BookExportService();

  Future<Uint8List> buildEpub({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required BookTemplate template,
    required BookSettings settings,
  }) async {
    final chapters = await repository.loadChapters(project);
    final sources = <BookEpubChapter>[];

    for (final chapter in chapters) {
      sources.add(
        BookEpubChapter(
          id: chapter.id,
          title: chapter.title,
          markdown: await repository.loadChapterMarkdown(project, chapter),
          parentId: chapter.parentId,
        ),
      );
    }

    return template.buildEpub(
      title: project.title,
      chapters: sources,
      settings: settings,
    );
  }
}
