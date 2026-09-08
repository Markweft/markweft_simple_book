import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markweft_simple_book/features/book_editor/presentation/widgets/book_settings_dialog.dart';
import 'package:markweft_template_simple/markweft_template_simple.dart';

void main() {
  testWidgets('book settings text and number fields keep focus while editing', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 5000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: BookSettingsPage(settings: BookSettings()),
      ),
    );
    await tester.pumpAndSettle();

    Finder fieldWithLabel(String label) {
      return find.byWidgetPredicate(
        (widget) =>
            widget is TextFormField && widget.decoration?.labelText == label,
      );
    }

    final titleField = fieldWithLabel('Title');
    expect(titleField, findsOneWidget);

    await tester.tap(titleField);
    await tester.pump();
    await tester.enterText(titleField, 'Focused Book');
    await tester.pump();

    var titleEditable = tester.widget<EditableText>(
      find.descendant(of: titleField, matching: find.byType(EditableText)),
    );
    expect(titleEditable.focusNode.hasFocus, isTrue);
    expect(titleEditable.controller.text, 'Focused Book');

    const nextTitle = 'Focused Book Again';
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: nextTitle,
        selection: TextSelection.collapsed(offset: nextTitle.length),
      ),
    );
    await tester.pump();

    titleEditable = tester.widget<EditableText>(
      find.descendant(of: titleField, matching: find.byType(EditableText)),
    );
    expect(titleEditable.focusNode.hasFocus, isTrue);
    expect(titleEditable.controller.text, nextTitle);

    final topMarginField = fieldWithLabel('Top margin (pt)');
    expect(topMarginField, findsOneWidget);

    await tester.tap(topMarginField);
    await tester.pump();
    await tester.enterText(topMarginField, '28');
    await tester.pump();

    final marginEditable = tester.widget<EditableText>(
      find.descendant(
        of: topMarginField,
        matching: find.byType(EditableText),
      ),
    );
    expect(marginEditable.focusNode.hasFocus, isTrue);
    expect(marginEditable.controller.text, '28');
  });
}
