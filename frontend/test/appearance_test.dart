import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/settings_picker.dart';
import 'package:garden_flutter/components/appearance/theme_color_control.dart';
import 'package:garden_flutter/components/account_background.dart';
import 'package:garden_flutter/components/settings/settings_sidebar.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/appearance/theme_profile.dart';
import 'package:garden_flutter/services/appearance_store.dart';
import 'package:garden_flutter/state/appearance_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

class MemoryAppearanceStore implements AppearanceStore {
  String? saved;
  bool fail = false;
  @override
  Future<String?> read() async => saved;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('Disk unavailable');
    saved = value;
  }
}

Future<void> preview(WidgetTester tester, String variant) async {
  const directory = String.fromEnvironment('APPEARANCE_PREVIEW_DIR');
  if (directory.isEmpty) return;
  await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('preview')),
    );
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File('$directory/garden-appearance-$variant.png')
        .writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  test(
    'persists both palettes and mode; failed writes retain saved state',
    () async {
      final store = MemoryAppearanceStore();
      final appearance = AppearanceController(store);
      await appearance.update(
        mode: ThemeMode.system,
        light: appearance.light.copyWith(
          accent: parseColor('#123456'),
          uiFont: 'Inter',
        ),
        dark: appearance.dark.copyWith(
          surface: parseColor('#151515'),
          contrast: 72,
        ),
      );
      final restored = AppearanceController(store);
      await restored.load();
      expect(restored.mode, ThemeMode.system);
      expect(restored.light.accent, parseColor('#123456'));
      expect(restored.light.uiFont, 'Inter');
      expect(restored.dark.surface, parseColor('#151515'));
      expect(restored.dark.contrast, 72);
      store.fail = true;
      await restored.update(mode: ThemeMode.dark);
      expect(restored.mode, ThemeMode.system);
      expect(restored.error, contains('Disk unavailable'));
      store.saved = '{invalid';
      await restored.load();
      expect(restored.error, contains('Could not load appearance'));
      appearance.dispose();
      restored.dispose();
    },
  );

  testWidgets(
    'appearance changes the app immediately and preserves login styling',
    (tester) async {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);
      tester.view.physicalSize = const Size(1100, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        for (final entry in const {
          'Geist': 'assets/fonts/Geist-Regular.ttf',
          'GeistMono': 'assets/fonts/GeistMono-Regular.ttf',
          'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
        }.entries) {
          final loader = FontLoader(entry.key)
            ..addFont(rootBundle.load(entry.value));
          await loader.load();
        }
      });
      final appearance = AppearanceController(MemoryAppearanceStore());
      final garden =
          GardenController(
              TestGateway(),
              MemoryPreferences(),
              appearance: appearance,
            )
            ..account = const AccountInfo(
              id: 'account',
              email: 'test@example.com',
            )
            ..page = GardenPage.settings
            ..settingsSection = SettingsSection.appearance;
      addTearDown(garden.dispose);
      await tester.pumpWidget(
        RepaintBoundary(
          key: const ValueKey('preview'),
          child: GardenApp(controller: garden),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsSidebar), findsOneWidget);
      var theme = Theme.of(tester.element(find.byType(SettingsSidebar)));
      expect(theme.colorScheme.surface, const Color(0xFFF9F9F7));
      expect(theme.colorScheme.onSurface, const Color(0xFF2D2D2B));
      expect(theme.colorScheme.primary, const Color(0xFFCC7D5E));
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light theme'), findsNothing);
      expect(find.text('Dark theme'), findsNothing);
      expect(find.text('Appearance'), findsNWidgets(2));
      await preview(tester, 'light');
      await tester.tap(find.byTooltip('Account menu'));
      await tester.pumpAndSettle();
      await preview(tester, 'menu-light');
      await tester.tapAt(const Offset(1000, 700));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Dark'));
      await tester.pumpAndSettle();
      expect(appearance.mode, ThemeMode.dark);
      theme = Theme.of(tester.element(find.byType(SettingsSidebar)));
      expect(theme.brightness, Brightness.dark);
      await preview(tester, 'dark');
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(find.text('Contrast'), findsOneWidget);
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      final color = find.byType(ThemeColorControl).first;
      await tester.enterText(
        find.descendant(of: color, matching: find.byType(TextField)),
        '#2468AC',
      );
      await tester.pump();
      await tester.tap(
        find.descendant(of: color, matching: find.byTooltip('Apply accent')),
      );
      await tester.pumpAndSettle();
      expect(appearance.dark.accent, parseColor('#2468AC'));
      await tester.enterText(
        find.descendant(of: color, matching: find.byType(TextField)),
        '#zzzzzz',
      );
      await tester.pump();
      await tester.tap(
        find.descendant(of: color, matching: find.byTooltip('Apply accent')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Use a color in #RRGGBB format.'), findsOneWidget);
      expect(appearance.dark.accent, parseColor('#2468AC'));
      await appearance.update(mode: ThemeMode.system);
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;
      addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(SettingsSidebar))).brightness,
        Brightness.dark,
      );
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          Brightness.light;
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(SettingsSidebar))).brightness,
        Brightness.light,
      );
      await tester.tap(find.byType(SettingsPicker<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sand').last);
      await tester.pumpAndSettle();
      expect(appearance.light.surface, parseColor('#FBF1C7'));
      expect(appearance.dark.surface, parseColor('#2D2D2B'));
      expect(appearance.dark.ink, parseColor('#F9F9F7'));
      expect(appearance.dark.contrast, 50);
      tester.view.physicalSize = const Size(900, 640);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      garden.navigate(GardenPage.signIn);
      await tester.pumpAndSettle();
      expect(find.byType(AccountBackground), findsOneWidget);
      theme = Theme.of(tester.element(find.byType(AccountBackground)));
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, GardenTheme.canvas);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'GoogleSans');
      expect(tester.takeException(), isNull);
      debugDisableShadows = true;
    },
  );
}
