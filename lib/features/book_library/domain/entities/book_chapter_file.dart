final class BookChapterFile {
  const BookChapterFile({
    required this.id,
    required this.title,
    required this.fileName,
    this.parentId,
  });

  final String id;
  final String title;
  final String fileName;
  final String? parentId;

  bool get isRoot => parentId == null;

  BookChapterFile copyWith({
    String? id,
    String? title,
    String? fileName,
    String? parentId,
    bool clearParent = false,
  }) {
    return BookChapterFile(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      parentId: clearParent ? null : parentId ?? this.parentId,
    );
  }
}
