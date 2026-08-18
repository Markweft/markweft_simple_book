final class BookChapterFile {
  const BookChapterFile({
    required this.id,
    required this.title,
    required this.fileName,
  });

  final String id;
  final String title;
  final String fileName;

  BookChapterFile copyWith({
    String? id,
    String? title,
    String? fileName,
  }) {
    return BookChapterFile(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
    );
  }
}
