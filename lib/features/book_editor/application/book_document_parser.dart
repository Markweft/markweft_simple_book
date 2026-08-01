import 'package:markweft_simple_book/features/book_editor/domain/entities/book_page.dart';
import 'package:yaml/yaml.dart';

final class BookDocumentParser {
  const BookDocumentParser();

  static final RegExp _pageDirective = RegExp(
    r'^[ \t]*<!--[ \t]*page(?<attributes>(?:[ \t]*\r?\n[\s\S]*?)?)[ \t]*-->[ \t]*$',
    caseSensitive: false,
    multiLine: true,
  );

  List<BookPageDocument> parse(
    String source, {
    BookPageSettings defaults = const BookPageSettings(),
  }) {
    final pages = <BookPageDocument>[];
    var cursor = 0;
    var nextSettings = defaults;

    for (final match in _pageDirective.allMatches(source)) {
      final content = source.substring(cursor, match.start).trim();

      if (content.isNotEmpty || pages.isEmpty) {
        pages.add(
          BookPageDocument(
            markdown: content,
            settings: nextSettings,
          ),
        );
      }

      final rawAttributes = match.namedGroup('attributes')?.trim() ?? '';
      nextSettings = rawAttributes.isEmpty
          ? defaults
          : _parseSettings(rawAttributes, defaults);
      cursor = match.end;
    }

    final remainingContent = source.substring(cursor).trim();
    if (remainingContent.isNotEmpty || pages.isEmpty) {
      pages.add(
        BookPageDocument(
          markdown: remainingContent,
          settings: nextSettings,
        ),
      );
    }

    return pages;
  }

  BookPageSettings _parseSettings(
    String source,
    BookPageSettings defaults,
  ) {
    try {
      final yaml = loadYaml(source);
      if (yaml is! YamlMap) {
        return defaults;
      }

      final map = _toStringMap(yaml);
      final orientationValue =
          map['orientation']?.toString() ?? map['oriantation']?.toString();

      return defaults.copyWith(
        size: _parseSize(map['size']?.toString()) ?? defaults.size,
        orientation: _parseOrientation(orientationValue) ??
            defaults.orientation,
        margin: _parseDimension(map['margin']) ?? defaults.margin,
        padding: _parseDimension(map['padding']) ?? defaults.padding,
        layout: _normalizeLayout(map['layout']) ?? defaults.layout,
        template: _parseTemplate(map['template']),
      );
    } on Object {
      return defaults;
    }
  }

  Map<String, Object?> _toStringMap(YamlMap yaml) {
    return <String, Object?>{
      for (final entry in yaml.entries)
        entry.key.toString(): _normalizeYaml(entry.value),
    };
  }

  Object? _normalizeYaml(Object? value) {
    return switch (value) {
      YamlMap() => <String, Object?>{
          for (final entry in value.entries)
            entry.key.toString(): _normalizeYaml(entry.value),
        },
      YamlList() => value.map(_normalizeYaml).toList(growable: false),
      _ => value,
    };
  }

  BookPageSize? _parseSize(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'a3' => BookPageSize.a3,
      'a4' => BookPageSize.a4,
      'a5' => BookPageSize.a5,
      'letter' => BookPageSize.letter,
      _ => null,
    };
  }

  BookPageOrientation? _parseOrientation(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'portrait' => BookPageOrientation.portrait,
      'landscape' => BookPageOrientation.landscape,
      _ => null,
    };
  }

  double? _parseDimension(Object? value) {
    final number = switch (value) {
      num() => value.toDouble(),
      String() => double.tryParse(value.trim()),
      _ => null,
    };

    if (number == null || number < 0 || number > 200) {
      return null;
    }

    return number;
  }

  String? _normalizeLayout(Object? value) {
    if (value == null) {
      return null;
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) {
      return null;
    }

    return raw.endsWith('.dart')
        ? raw.substring(0, raw.length - '.dart'.length)
        : raw;
  }

  Map<String, Object?> _parseTemplate(Object? value) {
    if (value is Map<String, Object?>) {
      return Map<String, Object?>.unmodifiable(value);
    }

    if (value is List<Object?>) {
      final result = <String, Object?>{};
      for (final item in value) {
        if (item case Map<String, Object?>()) {
          result.addAll(item);
        }
      }
      return Map<String, Object?>.unmodifiable(result);
    }

    return const <String, Object?>{};
  }
}
