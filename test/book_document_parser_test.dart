import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_editor/application/book_document_parser.dart';
import 'package:markweft_simple_book/features/book_editor/domain/entities/book_page.dart';

void main() {
  const parser = BookDocumentParser();

  test('splits markdown with a simple page directive', () {
    final pages = parser.parse('# One\n\n<!-- page -->\n\n# Two');

    expect(pages, hasLength(2));
    expect(pages.first.markdown, '# One');
    expect(pages.last.markdown, '# Two');
  });

  test('applies page attribute overrides to the following page', () {
    final pages = parser.parse('''
# One

<!-- page
layout: test.dart
size: a3
oriantation: landscape
margin: 12
padding: 36
template:
  title: Test
  description: Description
  image: image.png
-->

# Two
''');

    expect(pages, hasLength(2));
    final settings = pages.last.settings;
    expect(settings.layout, 'test');
    expect(settings.size, BookPageSize.a3);
    expect(settings.orientation, BookPageOrientation.landscape);
    expect(settings.margin, 12);
    expect(settings.padding, 36);
    expect(settings.template['title'], 'Test');
    expect(settings.template['image'], 'image.png');
  });
}
