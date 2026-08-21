import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/core/i18n/translations.g.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/visual_book_canvas.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  testWidgets('renders physical pages and supports navigation and zoom', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: const MaterialApp(
          home: Scaffold(
            body: VisualBookCanvas(
              template: SimpleBookTemplate(),
              settings: BookSettings(),
              chapterTitle: 'Chapter One',
              markdown: '# First\n\nFirst page.\n\n<!-- page -->\n\n# Second\n\nSecond page.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Visual canvas · Chapter One'), findsOneWidget);
    expect(find.text('Page 1 of 2'), findsOneWidget);
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2 of 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pumpAndSettle();
    expect(find.text('113%'), findsOneWidget);
  });
}
