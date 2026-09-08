import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookCompilationService {
  const BookCompilationService();

  Future<String> buildMarkdown({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required BookTemplate template,
    required BookSettings settings,
  }) async {
    final chapters = await repository.loadChapters(project);
    final buffer = StringBuffer();

    if (settings.tableOfContents.enabled && chapters.isNotEmpty) {
      final entries = <BookTocEntry>[
        for (final chapter in chapters)
          BookTocEntry(
            title: chapter.title,
            level: _depthOf(chapter, chapters),
          ),
      ];
      buffer.write(
        template.buildTableOfContentsMarkdown(
          entries: entries,
          settings: settings.tableOfContents,
        ),
      );
      buffer.write('\n\n');
    }

    for (var index = 0; index < chapters.length; index++) {
      if (index > 0) buffer.write('\n\n');
      buffer.write(await repository.loadChapterMarkdown(project, chapters[index]));
    }

    return buffer.toString();
  }

  int _depthOf(BookChapterFile chapter, List<BookChapterFile> chapters) {
    var depth = 1;
    var parentId = chapter.parentId;
    final visited = <String>{};

    while (parentId != null && visited.add(parentId)) {
      final parent = _findById(chapters, parentId);
      if (parent == null) break;
      depth++;
      parentId = parent.parentId;
    }

    return depth;
  }

  BookChapterFile? _findById(List<BookChapterFile> chapters, String id) {
    for (final chapter in chapters) {
      if (chapter.id == id) return chapter;
    }
    return null;
  }
}
