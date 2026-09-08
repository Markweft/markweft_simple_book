import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_library/data/mappers/book_settings_json.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

void main() {
  test('round trips publishing settings without losing book data', () {
    const settings = BookSettings(
      pageSize: BookPageSize.custom,
      customPageWidthMillimeters: 170,
      customPageHeightMillimeters: 240,
      orientation: BookPageOrientation.portrait,
      pageMargins: BookPageMargins(
        top: 28,
        bottom: 30,
        inside: 42,
        outside: 26,
      ),
      bleed: BookBleed.uniform(3),
      facingPages: true,
      languageCode: 'ar',
      direction: BookDirection.rtl,
      typography: BookTypographySettings(
        fontFamily: 'Noto Naskh Arabic',
        fontSize: 13,
        lineHeight: 1.7,
        embeddedPdfFontDataUri: 'data:font/ttf;base64,AAECAw==',
        embeddedPdfFontFileName: 'NotoNaskhArabic-Regular.ttf',
      ),
      defaultParagraphStyleId: 'lead',
      paragraphStyles: <ParagraphStyleDefinition>[
        ParagraphStyleDefinition(
          id: 'body',
          name: 'Body',
          fontSize: 12,
          lineHeight: 1.6,
        ),
        ParagraphStyleDefinition(
          id: 'lead',
          name: 'Lead',
          fontSize: 15,
          fontWeight: 600,
          firstLineIndent: 18,
          spaceAfter: 10,
        ),
      ],
      runningContent: RunningContentSettings(
        styleId: 'book-chapter',
        headerEnabled: true,
        footerEnabled: true,
        headerLeftPage: '{bookTitle}',
        headerRightPage: '{chapterTitle}',
        footerLeftPage: '{pageNumber}',
        footerRightPage: '{pageNumber}',
      ),
      cover: BookCoverSettings(
        mode: BookCoverMode.textOnly,
        styleId: 'minimal',
      ),
      metadata: BookMetadata(
        title: 'سحر الأحمر',
        subtitle: 'الجزء الأول',
        authors: <String>['Mostafa Khazaal'],
        publisher: 'Markweft',
        isbn: '978-0-00-000000-0',
        keywords: <String>['novel', 'arabic'],
      ),
    );

    final decoded = BookSettingsJson.decode(BookSettingsJson.encode(settings));

    expect(decoded.pageSize, BookPageSize.custom);
    expect(decoded.customPageWidthMillimeters, 170);
    expect(decoded.customPageHeightMillimeters, 240);
    expect(decoded.facingPages, isTrue);
    expect(decoded.pageMargins?.inside, 42);
    expect(decoded.pageMargins?.outside, 26);
    expect(decoded.bleed.top, 3);
    expect(decoded.bleed.right, 3);
    expect(decoded.direction, BookDirection.rtl);
    expect(decoded.languageCode, 'ar');
    expect(decoded.typography.fontFamily, 'Noto Naskh Arabic');
    expect(decoded.typography.fontSize, 13);
    expect(decoded.typography.embeddedPdfFontFileName, 'NotoNaskhArabic-Regular.ttf');
    expect(decoded.typography.embeddedPdfFontDataUri, 'data:font/ttf;base64,AAECAw==');
    expect(decoded.defaultParagraphStyleId, 'lead');
    expect(decoded.paragraphStyles, hasLength(2));
    expect(decoded.paragraphStyleFor('lead').firstLineIndent, 18);
    expect(decoded.runningContent.styleId, 'book-chapter');
    expect(decoded.runningContent.headerEnabled, isTrue);
    expect(decoded.runningContent.headerRightPage, '{chapterTitle}');
    expect(decoded.cover.mode, BookCoverMode.textOnly);
    expect(decoded.cover.styleId, 'minimal');
    expect(decoded.metadata.title, 'سحر الأحمر');
    expect(decoded.metadata.authors, <String>['Mostafa Khazaal']);
    expect(decoded.metadata.isbn, '978-0-00-000000-0');
  });

  test('decodes old 0.4 settings with backward-compatible defaults', () {
    final decoded = BookSettingsJson.decode('''
{
  "templateId": "markweft.simple",
  "pageSize": "a4",
  "orientation": "portrait",
  "margin": 24,
  "contentPadding": 48,
  "defaultColumns": 1,
  "languageCode": "en",
  "direction": "ltr",
  "colorMode": "light"
}
''');

    expect(decoded.pageSize, BookPageSize.a4);
    expect(decoded.pageMargins, isNull);
    expect(decoded.effectivePageMargins.inside, 24);
    expect(decoded.bleed.horizontal, 0);
    expect(decoded.facingPages, isFalse);
    expect(decoded.typography.hasEmbeddedPdfFont, isFalse);
    expect(decoded.runningContent.styleId, 'custom');
    expect(decoded.cover.mode, BookCoverMode.none);
    expect(decoded.metadata.title, isEmpty);
    expect(decoded.paragraphStyles, isNotEmpty);
  });
}
