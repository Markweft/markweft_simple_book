import 'dart:convert';

import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookSettingsJson {
  const BookSettingsJson._();

  static String encode(BookSettings settings) {
    final margins = settings.pageMargins;
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'templateId': settings.templateId,
      'pageSize': settings.pageSize.name,
      'orientation': settings.orientation.name,
      'margin': settings.margin,
      'pageMargins': margins == null
          ? null
          : <String, Object?>{
              'top': margins.top,
              'bottom': margins.bottom,
              'inside': margins.inside,
              'outside': margins.outside,
            },
      'contentPadding': settings.contentPadding,
      'bleed': <String, Object?>{
        'top': settings.bleed.top,
        'right': settings.bleed.right,
        'bottom': settings.bleed.bottom,
        'left': settings.bleed.left,
      },
      'facingPages': settings.facingPages,
      'customPageWidthMillimeters': settings.customPageWidthMillimeters,
      'customPageHeightMillimeters': settings.customPageHeightMillimeters,
      'defaultColumns': settings.defaultColumns,
      'languageCode': settings.languageCode,
      'direction': settings.direction.name,
      'colorMode': settings.colorMode.name,
      'typography': <String, Object?>{
        'fontFamily': settings.typography.fontFamily,
        'fontSize': settings.typography.fontSize,
        'fontWeight': settings.typography.fontWeight,
        'lineHeight': settings.typography.lineHeight,
        'alignment': settings.typography.alignment.name,
        'embeddedPdfFontDataUri': settings.typography.embeddedPdfFontDataUri,
        'embeddedPdfFontFileName': settings.typography.embeddedPdfFontFileName,
      },
      'defaultParagraphStyleId': settings.defaultParagraphStyleId,
      'paragraphStyles': [
        for (final style in settings.paragraphStyles)
          <String, Object?>{
            'id': style.id,
            'name': style.name,
            'fontFamily': style.fontFamily,
            'fontSize': style.fontSize,
            'fontWeight': style.fontWeight,
            'lineHeight': style.lineHeight,
            'alignment': style.alignment.name,
            'firstLineIndent': style.firstLineIndent,
            'spaceBefore': style.spaceBefore,
            'spaceAfter': style.spaceAfter,
            'startIndent': style.startIndent,
            'endIndent': style.endIndent,
          },
      ],
      'runningContent': <String, Object?>{
        'styleId': settings.runningContent.styleId,
        'headerEnabled': settings.runningContent.headerEnabled,
        'footerEnabled': settings.runningContent.footerEnabled,
        'headerLeftPage': settings.runningContent.headerLeftPage,
        'headerRightPage': settings.runningContent.headerRightPage,
        'footerLeftPage': settings.runningContent.footerLeftPage,
        'footerRightPage': settings.runningContent.footerRightPage,
        'showOnChapterOpenings':
            settings.runningContent.showOnChapterOpenings,
        'headerHeight': settings.runningContent.headerHeight,
        'footerHeight': settings.runningContent.footerHeight,
        'fontSize': settings.runningContent.fontSize,
        'fontWeight': settings.runningContent.fontWeight,
        'headerAlignment': settings.runningContent.headerAlignment.name,
        'footerAlignment': settings.runningContent.footerAlignment.name,
      },
      'cover': <String, Object?>{
        'mode': settings.cover.mode.name,
        'styleId': settings.cover.styleId,
        'imageDataUri': settings.cover.imageDataUri,
        'titleOverride': settings.cover.titleOverride,
        'subtitleOverride': settings.cover.subtitleOverride,
        'authorOverride': settings.cover.authorOverride,
        'overlayOpacity': settings.cover.overlayOpacity,
      },
      'metadata': <String, Object?>{
        'title': settings.metadata.title,
        'subtitle': settings.metadata.subtitle,
        'authors': settings.metadata.authors,
        'publisher': settings.metadata.publisher,
        'isbn': settings.metadata.isbn,
        'edition': settings.metadata.edition,
        'description': settings.metadata.description,
        'keywords': settings.metadata.keywords,
        'publishedDate': settings.metadata.publishedDate,
        'copyright': settings.metadata.copyright,
      },
      'tableOfContents': <String, Object?>{
        'enabled': settings.tableOfContents.enabled,
        'title': settings.tableOfContents.title,
        'maxDepth': settings.tableOfContents.maxDepth,
        'startOnNewPage': settings.tableOfContents.startOnNewPage,
        'includePageNumbers': settings.tableOfContents.includePageNumbers,
      },
    });
  }

  static BookSettings decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Book settings must be a JSON object.');
    }

    final typographyJson = _map(decoded['typography']);
    final typography = typographyJson == null
        ? const BookTypographySettings()
        : BookTypographySettings(
            fontFamily: _nullableString(typographyJson['fontFamily']),
            fontSize: _double(typographyJson['fontSize'], 12),
            fontWeight: _int(typographyJson['fontWeight'], 400),
            lineHeight: _double(typographyJson['lineHeight'], 1.5),
            alignment: _enumValue(
              BookTextAlignment.values,
              typographyJson['alignment'],
              BookTextAlignment.justify,
            ),
            embeddedPdfFontDataUri:
                _nullableString(typographyJson['embeddedPdfFontDataUri']),
            embeddedPdfFontFileName:
                _nullableString(typographyJson['embeddedPdfFontFileName']),
          );

    final marginsJson = _map(decoded['pageMargins']);
    final pageMargins = marginsJson == null
        ? null
        : BookPageMargins(
            top: _double(marginsJson['top'], 24),
            bottom: _double(marginsJson['bottom'], 24),
            inside: _double(marginsJson['inside'], 24),
            outside: _double(marginsJson['outside'], 24),
          );

    final bleedJson = _map(decoded['bleed']);
    final bleed = bleedJson == null
        ? const BookBleed()
        : BookBleed(
            top: _double(bleedJson['top'], 0),
            right: _double(bleedJson['right'], 0),
            bottom: _double(bleedJson['bottom'], 0),
            left: _double(bleedJson['left'], 0),
          );

    final styleItems = decoded['paragraphStyles'];
    final paragraphStyles = <ParagraphStyleDefinition>[];
    if (styleItems is List) {
      for (final item in styleItems) {
        final json = _map(item);
        if (json == null) continue;
        final id = _string(json['id'], '');
        if (id.isEmpty) continue;
        paragraphStyles.add(
          ParagraphStyleDefinition(
            id: id,
            name: _string(json['name'], id),
            fontFamily: _nullableString(json['fontFamily']),
            fontSize: _double(json['fontSize'], 12),
            fontWeight: _int(json['fontWeight'], 400),
            lineHeight: _double(json['lineHeight'], 1.5),
            alignment: _enumValue(
              BookTextAlignment.values,
              json['alignment'],
              BookTextAlignment.justify,
            ),
            firstLineIndent: _double(json['firstLineIndent'], 0),
            spaceBefore: _double(json['spaceBefore'], 0),
            spaceAfter: _double(json['spaceAfter'], 0),
            startIndent: _double(json['startIndent'], 0),
            endIndent: _double(json['endIndent'], 0),
          ),
        );
      }
    }

    final runningJson = _map(decoded['runningContent']);
    final runningContent = runningJson == null
        ? const RunningContentSettings()
        : RunningContentSettings(
            styleId: _string(runningJson['styleId'], 'custom'),
            headerEnabled: _bool(runningJson['headerEnabled'], false),
            footerEnabled: _bool(runningJson['footerEnabled'], false),
            headerLeftPage:
                _string(runningJson['headerLeftPage'], '{bookTitle}'),
            headerRightPage:
                _string(runningJson['headerRightPage'], '{chapterTitle}'),
            footerLeftPage:
                _string(runningJson['footerLeftPage'], '{pageNumber}'),
            footerRightPage:
                _string(runningJson['footerRightPage'], '{pageNumber}'),
            showOnChapterOpenings:
                _bool(runningJson['showOnChapterOpenings'], false),
            headerHeight: _double(runningJson['headerHeight'], 28),
            footerHeight: _double(runningJson['footerHeight'], 28),
            fontSize: _double(runningJson['fontSize'], 9),
            fontWeight: _int(runningJson['fontWeight'], 400),
            headerAlignment: _enumValue(
              RunningContentAlignment.values,
              runningJson['headerAlignment'],
              RunningContentAlignment.start,
            ),
            footerAlignment: _enumValue(
              RunningContentAlignment.values,
              runningJson['footerAlignment'],
              RunningContentAlignment.center,
            ),
          );

    final coverJson = _map(decoded['cover']);
    final cover = coverJson == null
        ? const BookCoverSettings()
        : BookCoverSettings(
            mode: _enumValue(
              BookCoverMode.values,
              coverJson['mode'],
              BookCoverMode.none,
            ),
            styleId: _string(coverJson['styleId'], 'classic'),
            imageDataUri: _nullableString(coverJson['imageDataUri']),
            titleOverride: _string(coverJson['titleOverride'], ''),
            subtitleOverride: _string(coverJson['subtitleOverride'], ''),
            authorOverride: _string(coverJson['authorOverride'], ''),
            overlayOpacity: _double(coverJson['overlayOpacity'], 0.32),
          );

    final metadataJson = _map(decoded['metadata']);
    final metadata = metadataJson == null
        ? const BookMetadata()
        : BookMetadata(
            title: _string(metadataJson['title'], ''),
            subtitle: _string(metadataJson['subtitle'], ''),
            authors: _stringList(metadataJson['authors']),
            publisher: _string(metadataJson['publisher'], ''),
            isbn: _string(metadataJson['isbn'], ''),
            edition: _string(metadataJson['edition'], ''),
            description: _string(metadataJson['description'], ''),
            keywords: _stringList(metadataJson['keywords']),
            publishedDate: _string(metadataJson['publishedDate'], ''),
            copyright: _string(metadataJson['copyright'], ''),
          );

    final tocJson = _map(decoded['tableOfContents']);
    final tableOfContents = tocJson == null
        ? const BookTocSettings()
        : BookTocSettings(
            enabled: _bool(tocJson['enabled'], false),
            title: _string(tocJson['title'], 'Table of Contents'),
            maxDepth: _depth(tocJson['maxDepth']),
            startOnNewPage: _bool(tocJson['startOnNewPage'], true),
            includePageNumbers: _bool(tocJson['includePageNumbers'], false),
          );

    return BookSettings(
      templateId: _string(decoded['templateId'], 'markweft.simple'),
      pageSize: _enumValue(
        BookPageSize.values,
        decoded['pageSize'],
        BookPageSize.a4,
      ),
      orientation: _enumValue(
        BookPageOrientation.values,
        decoded['orientation'],
        BookPageOrientation.portrait,
      ),
      margin: _double(decoded['margin'], 24),
      pageMargins: pageMargins,
      contentPadding: _double(decoded['contentPadding'], 48),
      bleed: bleed,
      facingPages: _bool(decoded['facingPages'], false),
      customPageWidthMillimeters:
          _double(decoded['customPageWidthMillimeters'], 210),
      customPageHeightMillimeters:
          _double(decoded['customPageHeightMillimeters'], 297),
      defaultColumns: _columns(decoded['defaultColumns']),
      languageCode: _string(decoded['languageCode'], 'en'),
      direction: _enumValue(
        BookDirection.values,
        decoded['direction'],
        BookDirection.ltr,
      ),
      colorMode: _enumValue(
        BookColorMode.values,
        decoded['colorMode'],
        BookColorMode.light,
      ),
      typography: typography,
      paragraphStyles: paragraphStyles.isEmpty
          ? simpleDefaultParagraphStyles
          : List<ParagraphStyleDefinition>.unmodifiable(paragraphStyles),
      defaultParagraphStyleId:
          _string(decoded['defaultParagraphStyleId'], 'body'),
      runningContent: runningContent,
      cover: cover,
      metadata: metadata,
      tableOfContents: tableOfContents,
    );
  }

  static Map<String, dynamic>? _map(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const <String>[];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static String _string(Object? value, String fallback) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int _int(Object? value, int fallback) {
    return value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  }

  static int _columns(Object? value) {
    final parsed = _int(value, 1);
    if (parsed < 1) return 1;
    if (parsed > 3) return 3;
    return parsed;
  }

  static int _depth(Object? value) {
    final parsed = _int(value, 3);
    if (parsed < 1) return 1;
    if (parsed > 6) return 6;
    return parsed;
  }

  static bool _bool(Object? value, bool fallback) {
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
  }

  static double _double(Object? value, double fallback) {
    return value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? fallback;
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    final name = raw?.toString();
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }
}
