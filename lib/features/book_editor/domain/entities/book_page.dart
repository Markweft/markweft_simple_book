enum BookPageSize {
  a3,
  a4,
  a5,
  letter,
}

enum BookPageOrientation {
  portrait,
  landscape,
}

final class BookPageSettings {
  const BookPageSettings({
    this.size = BookPageSize.a4,
    this.orientation = BookPageOrientation.portrait,
    this.margin = 24,
    this.padding = 48,
    this.layout = 'default',
    this.template = const <String, Object?>{},
  });

  final BookPageSize size;
  final BookPageOrientation orientation;
  final double margin;
  final double padding;
  final String layout;
  final Map<String, Object?> template;

  BookPageSettings copyWith({
    BookPageSize? size,
    BookPageOrientation? orientation,
    double? margin,
    double? padding,
    String? layout,
    Map<String, Object?>? template,
  }) {
    return BookPageSettings(
      size: size ?? this.size,
      orientation: orientation ?? this.orientation,
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      layout: layout ?? this.layout,
      template: template ?? this.template,
    );
  }

  double get width {
    final (portraitWidth, portraitHeight) = switch (size) {
      BookPageSize.a3 => (297.0, 420.0),
      BookPageSize.a4 => (210.0, 297.0),
      BookPageSize.a5 => (148.0, 210.0),
      BookPageSize.letter => (215.9, 279.4),
    };

    return orientation == BookPageOrientation.portrait
        ? portraitWidth
        : portraitHeight;
  }

  double get height {
    final (portraitWidth, portraitHeight) = switch (size) {
      BookPageSize.a3 => (297.0, 420.0),
      BookPageSize.a4 => (210.0, 297.0),
      BookPageSize.a5 => (148.0, 210.0),
      BookPageSize.letter => (215.9, 279.4),
    };

    return orientation == BookPageOrientation.portrait
        ? portraitHeight
        : portraitWidth;
  }

  double get aspectRatio => width / height;
}

final class BookPageDocument {
  const BookPageDocument({
    required this.markdown,
    required this.settings,
  });

  final String markdown;
  final BookPageSettings settings;
}
