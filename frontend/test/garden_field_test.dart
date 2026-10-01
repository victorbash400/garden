import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/garden_field.dart';

void main() {
  testWidgets('Password visibility preserves text and starts hidden', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'test password');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GardenField(
            label: 'Password',
            controller: controller,
            obscure: true,
          ),
        ),
      ),
    );
    TextField field() => tester.widget<TextField>(find.byType(TextField));
    expect(field().obscureText, isTrue);
    expect(field().autocorrect, isFalse);
    expect(field().enableSuggestions, isFalse);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    expect(controller.text, 'test password');
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(field().obscureText, isTrue);
    expect(controller.text, 'test password');
  });
}
