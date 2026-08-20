import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

abstract interface class BookProjectRepository {
  Future<MarkweftProject?> createProject({required String title});

  Future<MarkweftProject?> importMarkdown({required String title});

  Future<MarkweftProject?> pickAndOpenProject();

  Future<MarkweftProject> openProject(String projectPath);

  Future<String?> pickAndConvertProjectVersion({required int targetVersion});

  Future<List<BookChapterFile>> loadChapters(MarkweftProject project);

  Future<BookChapterFile> createChapter(
    MarkweftProject project, {
    required String title,
  });

  Future<String> loadChapterMarkdown(
    MarkweftProject project,
    BookChapterFile chapter,
  );

  Future<void> saveChapterMarkdown(
    MarkweftProject project,
    BookChapterFile chapter,
    String markdown,
  );

  Future<String> loadWholeBookMarkdown(MarkweftProject project);

  Future<void> flushProject(MarkweftProject project);

  Future<String> loadMarkdown(MarkweftProject project);

  Future<void> saveMarkdown(
    MarkweftProject project,
    String markdown,
  );

  Future<BookSettings> loadBookSettings(MarkweftProject project);

  Future<void> saveBookSettings(
    MarkweftProject project,
    BookSettings settings,
  );

  Future<void> closeProject(MarkweftProject project);
}
