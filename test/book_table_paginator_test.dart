import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_table_paginator.dart';
import 'package:markweft_simple_book/features/book_editor/domain/entities/book_page.dart';

void main() {
  const paginator = BookTablePaginator();

  test('keeps a small table on one page', () {
    final pages = paginator.paginate(
      const <BookPageDocument>[
        BookPageDocument(
          markdown: '''
| Name | Age |
|---|---|
| Ali | 20 |
| Sara | 21 |
''',
          settings: BookPageSettings(),
        ),
      ],
    );

    expect(pages, hasLength(1));
  });

  test('splits a tall A4 table and repeats its header', () {
    final rows = List<String>.generate(
      40,
      (index) => '| Person $index | ${20 + index} |',
    ).join('\n');

    final pages = paginator.paginate(
      <BookPageDocument>[
        BookPageDocument(
          markdown: '''
# People

| Name | Age |
|---|---|
$rows

After the table.
''',
          settings: const BookPageSettings(),
        ),
      ],
    );

    expect(pages.length, greaterThan(1));
    expect(pages.first.markdown, contains('# People'));
    expect(pages.last.markdown, contains('After the table.'));

    for (final page in pages) {
      expect(page.markdown, contains('| Name | Age |'));
      expect(page.markdown, contains('|---|---|'));
    }
  });
}
