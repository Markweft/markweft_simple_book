import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

abstract interface class BookProjectRepository {
  Future<MarkweftProject?> createProject({required String title});

  Future<MarkweftProject?> importMarkdown({required String title});

  Future<MarkweftProject?> pickAndOpenProject();

  Future<MarkweftProject> openProject(String projectPath);

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
