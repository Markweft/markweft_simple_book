import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/main.dart';

void main() {
  testWidgets(
    'renders the Markdown editor and book preview',
        (tester) async {
      await tester.pumpWidget(
        const MarkweftSimpleBookApp(),
      );

      expect(
        find.text('Markweft Simple Book'),
        findsOneWidget,
      );

      expect(
        find.text('Markdown'),
        findsOneWidget,
      );

      expect(
        find.text('The Lost Kingdom'),
        findsWidgets,
      );
    },
  );
}