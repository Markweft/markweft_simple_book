import 'package:markweft_simple_book/features/book_editor/domain/entities/book_page.dart';

/// Splits unusually tall Markdown tables into multiple physical preview pages.
///
/// This is intentionally row-based for the first implementation. A future
/// renderer can replace the heuristic with measured block pagination.
final class BookTablePaginator {
  const BookTablePaginator();

  static final RegExp _tableSeparator = RegExp(
    r'^\s*\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$',
  );

  List<BookPageDocument> paginate(List<BookPageDocument> logicalPages) {
    return logicalPages.expand(_paginatePage).toList(growable: false);
  }

  List<BookPageDocument> _paginatePage(BookPageDocument page) {
    final lines = page.markdown.split('\n');
    final table = _findLargeTable(lines, page.settings);

    if (table == null) {
      return <BookPageDocument>[page];
    }

    final before = lines.sublist(0, table.start);
    final after = lines.sublist(table.end);
    final rows = lines.sublist(table.start + 2, table.end);
    final chunks = <List<String>>[];

    for (var index = 0; index < rows.length; index += table.rowsPerPage) {
      final end = (index + table.rowsPerPage).clamp(0, rows.length);
      chunks.add(rows.sublist(index, end));
    }

    final result = <BookPageDocument>[];

    for (var index = 0; index < chunks.length; index++) {
      final markdownLines = <String>[
        if (index == 0) ...before,
        lines[table.start],
        lines[table.start + 1],
        ...chunks[index],
        if (index == chunks.length - 1) ...after,
      ];

      result.add(
        BookPageDocument(
          markdown: markdownLines.join('\n').trim(),
          settings: page.settings,
        ),
      );
    }

    return result;
  }

  _TableRange? _findLargeTable(
    List<String> lines,
    BookPageSettings settings,
  ) {
    final rowsPerPage = _rowsPerPage(settings);

    for (var index = 0; index < lines.length - 1; index++) {
      if (!_looksLikeTableRow(lines[index]) ||
          !_tableSeparator.hasMatch(lines[index + 1])) {
        continue;
      }

      var end = index + 2;
      while (end < lines.length && _looksLikeTableRow(lines[end])) {
        end++;
      }

      final bodyRowCount = end - (index + 2);
      if (bodyRowCount > rowsPerPage) {
        return _TableRange(
          start: index,
          end: end,
          rowsPerPage: rowsPerPage,
        );
      }
    }

    return null;
  }

  bool _looksLikeTableRow(String line) {
    final trimmed = line.trim();
    return trimmed.contains('|') && !trimmed.startsWith('```');
  }

  int _rowsPerPage(BookPageSettings settings) {
    final base = switch (settings.size) {
      BookPageSize.a3 => 28,
      BookPageSize.a4 => 18,
      BookPageSize.a5 => 11,
      BookPageSize.letter => 17,
    };

    final orientationAdjustment =
        settings.orientation == BookPageOrientation.landscape ? -5 : 0;
    final paddingAdjustment = ((settings.padding - 48) / 8).round();

    return (base + orientationAdjustment - paddingAdjustment).clamp(5, 40);
  }
}

final class _TableRange {
  const _TableRange({
    required this.start,
    required this.end,
    required this.rowsPerPage,
  });

  final int start;
  final int end;
  final int rowsPerPage;
}
