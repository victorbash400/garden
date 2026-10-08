import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/window_appearance.dart';
import 'package:garden_flutter/native/account_window.dart';
import 'package:garden_flutter/model/appearance/theme_presets.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

void main() {
  testWidgets('syncs palette and system brightness without repeated calls', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    final window = AccountWindow();
    addTearDown(window.dispose);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      AccountWindow.channel,
      (call) async => calls.add(call),
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        AccountWindow.channel,
        null,
      );
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue();
    });
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.light;
    Widget app(Color color) => MaterialApp(
      theme: GardenTheme.profile(
        lightPresets.first.copyWith(surface: color),
        Brightness.light,
      ),
      darkTheme: GardenTheme.profile(darkPresets.first, Brightness.dark),
      themeMode: ThemeMode.system,
      themeAnimationDuration: Duration.zero,
      builder: (context, child) => WindowAppearance(
        window: window,
        onError: (error) => fail('$error'),
        child: child!,
      ),
      home: const SizedBox(),
    );
    await tester.pumpWidget(app(const Color(0xFFFBF1C7)));
    await tester.pumpAndSettle();
    expect(calls.single.method, 'appearance');
    expect(calls.single.arguments, {'color': 0xFFFBF1C7, 'dark': false});
    await tester.pumpWidget(app(const Color(0xFFFBF1C7)));
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    await tester.pumpWidget(app(const Color(0xFFEDF5EE)));
    await tester.pumpAndSettle();
    expect(calls.last.arguments, {'color': 0xFFEDF5EE, 'dark': false});
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    await tester.pumpAndSettle();
    expect(calls.last.arguments, {
      'color': darkPresets.first.surface.toARGB32(),
      'dark': true,
    });
    expect(calls, hasLength(3));
  });
}
