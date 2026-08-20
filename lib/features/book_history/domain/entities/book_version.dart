final class BookVersion {
  const BookVersion({
    required this.id,
    required this.createdAt,
    required this.reason,
    required this.message,
    required this.stateHash,
    required this.settingsObject,
    required this.chapters,
  });

  final String id;
  final DateTime createdAt;
  final String reason;
  final String message;
  final String stateHash;
  final String settingsObject;
  final List<BookVersionChapter> chapters;

  bool get isManual => reason == 'manual';
}

final class BookVersionChapter {
  const BookVersionChapter({
    required this.id,
    required this.title,
    required this.fileName,
    required this.object,
  });

  final String id;
  final String title;
  final String fileName;
  final String object;
}
