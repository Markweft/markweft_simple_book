import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markweft_simple_book/features/book_library/domain/entities/book_chapter_file.dart';
import 'package:markweft_simple_book/features/book_library/domain/entities/markweft_project.dart';
import 'package:markweft_simple_book/features/book_library/domain/repositories/book_project_repository.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

final class BookExportService {
  const BookExportService();

  Future<String> buildHtml({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required BookSettings settings,
  }) async {
    final chapters = await repository.loadChapters(project);
    final body = StringBuffer();

    for (final chapter in chapters) {
      final markdown = await repository.loadChapterMarkdown(project, chapter);
      body
        ..writeln('<article class="chapter" id="${_escapeAttribute(chapter.id)}">')
        ..writeln(md.markdownToHtml(markdown, extensionSet: md.ExtensionSet.gitHubWeb))
        ..writeln('</article>');
    }

    final direction = settings.direction == BookDirection.rtl ? 'rtl' : 'ltr';
    final language = _escapeAttribute(settings.languageCode);
    final fontFamily = _cssFontFamily(settings.typography.fontFamily);
    final alignment = _cssTextAlignment(settings.typography.alignment);

    return '''<!doctype html>
<html lang="$language" dir="$direction">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>${_escapeHtml(project.title)}</title>
  <style>
    :root { color-scheme: light dark; }
    body {
      margin: 0;
      font-family: $fontFamily;
      font-size: ${settings.typography.fontSize}px;
      line-height: ${settings.typography.lineHeight};
      font-weight: ${settings.typography.fontWeight};
      text-align: $alignment;
      background: #f4f1ec;
      color: #2b2520;
    }
    main {
      width: min(100% - 32px, 960px);
      margin: 0 auto;
      padding: 40px 0 80px;
    }
    .chapter {
      background: white;
      padding: 48px;
      margin: 0 0 28px;
      box-shadow: 0 8px 28px rgba(0,0,0,.10);
      border-radius: 8px;
    }
    img { max-width: 100%; height: auto; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #c9c2b8; padding: 8px; }
    pre { overflow: auto; padding: 14px; background: #f4f4f4; }
    code { overflow-wrap: anywhere; }
    @media (max-width: 640px) {
      main { width: 100%; padding: 0; }
      .chapter { border-radius: 0; margin: 0; padding: 24px 18px; box-shadow: none; }
    }
  </style>
</head>
<body>
<main>
${body.toString()}
</main>
</body>
</html>
''';
  }

  Future<Uint8List> buildEpub({
    required MarkweftProject project,
    required BookProjectRepository repository,
    required BookSettings settings,
  }) async {
    final chapters = await repository.loadChapters(project);
    final archive = Archive();

    _addText(archive, 'mimetype', 'application/epub+zip');
    _addText(
      archive,
      'META-INF/container.xml',
      '''<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/>
  </rootfiles>
</container>''',
    );

    final manifest = StringBuffer();
    final spine = StringBuffer();
    final navItems = StringBuffer();

    for (var index = 0; index < chapters.length; index++) {
      final chapter = chapters[index];
      final id = 'chapter-${index + 1}';
      final fileName = '$id.xhtml';
      final markdown = await repository.loadChapterMarkdown(project, chapter);
      final content = md.markdownToHtml(
        markdown,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );

      _addText(
        archive,
        'OEBPS/$fileName',
        _chapterXhtml(
          title: chapter.title,
          content: content,
          language: settings.languageCode,
          direction: settings.direction,
        ),
      );

      manifest.writeln(
        '<item id="$id" href="$fileName" media-type="application/xhtml+xml"/>',
      );
      spine.writeln('<itemref idref="$id"/>');
      navItems.writeln(
        '<li><a href="$fileName">${_escapeHtml(chapter.title)}</a></li>',
      );
    }

    _addText(
      archive,
      'OEBPS/styles.css',
      _epubCss(settings),
    );
    _addText(
      archive,
      'OEBPS/nav.xhtml',
      _navXhtml(
        title: project.title,
        language: settings.languageCode,
        direction: settings.direction,
        items: navItems.toString(),
      ),
    );
    _addText(
      archive,
      'OEBPS/content.opf',
      _contentOpf(
        title: project.title,
        language: settings.languageCode,
        manifest: manifest.toString(),
        spine: spine.toString(),
      ),
    );

    final bytes = ZipEncoder().encode(archive);
    return Uint8List.fromList(bytes);
  }

  void _addText(Archive archive, String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  String _chapterXhtml({
    required String title,
    required String content,
    required String language,
    required BookDirection direction,
  }) {
    final dir = direction == BookDirection.rtl ? 'rtl' : 'ltr';
    return '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="${_escapeAttribute(language)}" dir="$dir">
<head>
  <title>${_escapeHtml(title)}</title>
  <link rel="stylesheet" type="text/css" href="styles.css"/>
</head>
<body>
<section class="chapter">
$content
</section>
</body>
</html>''';
  }

  String _navXhtml({
    required String title,
    required String language,
    required BookDirection direction,
    required String items,
  }) {
    final dir = direction == BookDirection.rtl ? 'rtl' : 'ltr';
    return '''<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="${_escapeAttribute(language)}" dir="$dir">
<head><title>${_escapeHtml(title)}</title></head>
<body>
<nav epub:type="toc" id="toc">
  <h1>${_escapeHtml(title)}</h1>
  <ol>
$items
  </ol>
</nav>
</body>
</html>''';
  }

  String _contentOpf({
    required String title,
    required String language,
    required String manifest,
    required String spine,
  }) {
    final identifier = 'urn:uuid:${DateTime.now().microsecondsSinceEpoch}';
    return '''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="book-id">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="book-id">$identifier</dc:identifier>
    <dc:title>${_escapeHtml(title)}</dc:title>
    <dc:language>${_escapeHtml(language)}</dc:language>
    <meta property="dcterms:modified">${DateTime.now().toUtc().toIso8601String().split('.').first}Z</meta>
  </metadata>
  <manifest>
    <item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>
    <item id="css" href="styles.css" media-type="text/css"/>
$manifest
  </manifest>
  <spine>
$spine
  </spine>
</package>''';
  }

  String _epubCss(BookSettings settings) {
    return '''body {
  font-family: ${_cssFontFamily(settings.typography.fontFamily)};
  font-size: ${settings.typography.fontSize}px;
  line-height: ${settings.typography.lineHeight};
  font-weight: ${settings.typography.fontWeight};
  text-align: ${_cssTextAlignment(settings.typography.alignment)};
}
img { max-width: 100%; height: auto; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #888; padding: .45em; }
pre { overflow-x: auto; }
''';
  }

  String _cssFontFamily(String? value) {
    return switch (value) {
      'serif' => 'serif',
      'monospace' => 'monospace',
      'sans-serif' => 'sans-serif',
      null || 'system' => 'system-ui, sans-serif',
      _ => '"${value.replaceAll('"', '')}", sans-serif',
    };
  }

  String _cssTextAlignment(BookTextAlignment alignment) {
    return switch (alignment) {
      BookTextAlignment.start => 'start',
      BookTextAlignment.left => 'left',
      BookTextAlignment.center => 'center',
      BookTextAlignment.right => 'right',
      BookTextAlignment.justify => 'justify',
    };
  }

  String _escapeHtml(String value) {
    return const HtmlEscape(HtmlEscapeMode.element).convert(value);
  }

  String _escapeAttribute(String value) {
    return const HtmlEscape(HtmlEscapeMode.attribute).convert(value);
  }
}
