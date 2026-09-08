import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/smart_markdown_editor.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

void main() {
  Future<TextField> pumpEditor(
    WidgetTester tester,
    String source,
  ) async {
    final controller = SmartMarkdownController(text: source);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 500,
            child: SmartMarkdownEditor(
              controller: controller,
              actions: const <TemplateToolbarAction>{
                TemplateToolbarAction.paragraphStyle,
              },
              onChanged: (_) {},
              hintText: 'Markdown',
            ),
          ),
        ),
      ),
    );
    return tester.widget<TextField>(find.byType(TextField));
  }

  testWidgets('uses RTL for Arabic Markdown', (tester) async {
    final field = await pumpEditor(tester, '# الفصل الأول\n\nهذا نص عربي.');

    expect(field.textDirection, TextDirection.rtl);
    expect(field.textAlign, TextAlign.start);
  });

  testWidgets('uses LTR for English Markdown', (tester) async {
    final field = await pumpEditor(tester, '# Chapter One\n\nEnglish text.');

    expect(field.textDirection, TextDirection.ltr);
    expect(field.textAlign, TextAlign.start);
  });
}
