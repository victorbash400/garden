import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/cache_limit_control.dart';
import 'package:garden_flutter/model/cache_usage.dart';
import 'package:garden_flutter/services/cache_store.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';

import 'widget_test.dart' show TestGateway;

class TestCacheStore implements CacheStore {
  CacheUsage usage = const CacheUsage(
    limitBytes: 4 * CacheUsage.gib,
    available: true,
    usedBytes: CacheUsage.gib ~/ 2,
    blocks: 512,
  );
  String? failure;
  int requests = 0;

  @override
  Future<int> readCacheLimit() async => usage.limitGiB;
  @override
  Future<void> saveCacheLimit(int gib) async => setCacheLimit(gib);
  @override
  Future<CacheUsage> cacheUsage() async {
    requests++;
    if (failure != null) throw StateError(failure!);
    return usage;
  }

  @override
  Future<CacheUsage> setCacheLimit(int gib) async {
    if (failure != null) throw StateError(failure!);
    usage = CacheUsage(
      limitBytes: gib * CacheUsage.gib,
      available: true,
      usedBytes: gib == 0 ? 0 : usage.usedBytes,
      blocks: gib == 0 ? 0 : usage.blocks,
    );
    return usage;
  }

  @override
  Future<CacheUsage> clearCache() async {
    usage = CacheUsage(
      limitBytes: usage.limitBytes,
      available: true,
      usedBytes: 0,
      blocks: 0,
    );
    return usage;
  }
}

void main() {
  testWidgets(
    'shows real usage, clears blocks, and applies zero cache without polling',
    (tester) async {
      final store = TestCacheStore();
      final controller = GardenController(TestGateway(), store);
      controller.page = GardenPage.settings;
      controller.settingsSection = SettingsSection.storage;
      await tester.pumpWidget(GardenApp(controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('512.0 MiB used'), findsOneWidget);
      expect(find.text('4.0 GiB limit'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.125);
      await tester.pump(const Duration(seconds: 30));
      expect(store.requests, 1);
      await tester.tap(find.text('Clear cache'));
      await tester.pumpAndSettle();
      expect(find.text('0 B used'), findsOneWidget);
      await controller.setCacheLimit(0);
      await tester.pumpAndSettle();
      expect(find.text('No disk cache'), findsOneWidget);
      expect(store.usage.limitBytes, 0);
      final control = tester.widget<SliderTheme>(
        find
            .descendant(
              of: find.byType(CacheLimitControl),
              matching: find.byType(SliderTheme),
            )
            .first,
      );
      expect(control.data.overlayShape, SliderComponentShape.noOverlay);
    },
  );

  testWidgets(
    'failed limit changes retain the enforced limit and display the error',
    (tester) async {
      final store = TestCacheStore();
      final controller = GardenController(TestGateway(), store);
      controller.page = GardenPage.settings;
      controller.settingsSection = SettingsSection.storage;
      await tester.pumpWidget(GardenApp(controller: controller));
      await tester.pumpAndSettle();
      store.failure = 'Finder cache unavailable';
      await controller.setCacheLimit(1);
      await tester.pumpAndSettle();
      expect(controller.storage!.usage!.limitGiB, 4);
      expect(find.textContaining('Finder cache unavailable'), findsWidgets);
    },
  );
}
