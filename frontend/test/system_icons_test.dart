import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/system_icon.dart';

void main() {
  testWidgets('every migrated icon renders from its bundled SVG', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final icon in SystemIcons.values)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: SystemIcon(icon, size: 24),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SystemIcon), findsNWidgets(SystemIcons.values.length));
    expect(tester.takeException(), isNull);
  });
}
