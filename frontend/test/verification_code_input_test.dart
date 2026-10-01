import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/verification_code_input.dart';

void main() {
  testWidgets(
    'Pasted code fills all boxes and backspace moves to previous box',
    (tester) async {
      var code = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 380,
              child: VerificationCodeInput(
                enabled: true,
                onChanged: (value) => code = value,
                onSubmitted: () {},
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField).first, 'AB12cd34');
      await tester.pump();
      expect(code, 'ab12cd34');
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields.map((field) => field.controller!.text).join(), 'ab12cd34');
      await tester.enterText(find.byType(TextField).last, '');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(fields[6].focusNode!.hasFocus, isTrue);
      expect(code, 'ab12cd');
    },
  );
}
