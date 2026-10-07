import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/sign_in_field_icon.dart';
import 'package:garden_flutter/components/system_icon.dart';

void main() {
  testWidgets('field constraints do not stretch sign-in glyphs or badges', (
    tester,
  ) async {
    for (final width in [180.0, 320.0]) {
      for (final password in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: SignInFieldIcon(password: password),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 19),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final glyph = tester.getRect(find.byType(SystemIcon));
        final circle = tester.getRect(
          find.byWidgetPredicate(
            (widget) =>
                widget is DecoratedBox &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle,
          ),
        );
        expect(glyph.size, const Size(18, 18));
        expect(circle.size, const Size(34, 34));
        expect(glyph.center, circle.center);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
