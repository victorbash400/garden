import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/files/file_opening_status.dart';
import 'package:garden_flutter/components/profile_button.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/mac_finder_updates.dart';
import 'package:garden_flutter/native/finder_status.dart';
import 'package:garden_flutter/native/finder_updates.dart';
import 'package:garden_flutter/state/file_opening_controller.dart';
import 'package:garden_flutter/state/files_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' show TestGateway, MemoryPreferences;

void main() {
  testWidgets('Finder status cannot remain connecting without a first event', (
    tester,
  ) async {
    final events = StreamController<FinderStatus>.broadcast();
    final updates = MacFinderUpdates(watch: (_, _) => events.stream);
    final syncing = updates.sync(
      const AccountInfo(id: 'account', email: 'test@example.com'),
      [const GardenInfo(id: 7, name: 'Drive', role: 'Owner', members: 1)],
    );
    await tester.pump();
    await syncing;
    expect(updates.state, FinderUpdateState.connecting);
    await tester.pump(const Duration(seconds: 45));
    expect(updates.state, FinderUpdateState.disconnected);
    expect(updates.error, contains('drive status'));
    events.add(const FinderStatus(registered: {7}, enabled: {7}));
    await tester.pump();
    expect(updates.state, FinderUpdateState.disconnected);
    await tester.runAsync(() async {
      await updates.close();
      await events.close();
    });
    updates.dispose();
  });
  testWidgets('a received Finder status cancels the initial deadline', (
    tester,
  ) async {
    final events = StreamController<FinderStatus>.broadcast();
    final updates = MacFinderUpdates(watch: (_, _) => events.stream);
    final syncing = updates.sync(
      const AccountInfo(id: 'account', email: 'test@example.com'),
      [const GardenInfo(id: 7, name: 'Drive', role: 'Owner', members: 1)],
    );
    await tester.pump();
    await syncing;
    events.add(const FinderStatus(registered: {7}, enabled: {7}));
    await tester.pump();
    await tester.pump(const Duration(seconds: 46));
    expect(updates.state, FinderUpdateState.running);
    await tester.runAsync(() async {
      await updates.close();
      await events.close();
    });
    updates.dispose();
  });
  testWidgets('startup stops waiting for an unresponsive preference read', (
    tester,
  ) async {
    final preferences = PendingPreferences();
    final garden = GardenController(TestGateway(), preferences);
    final initialized = garden.initialize();
    await tester.pump();
    await tester.pump(const Duration(seconds: 15));
    await initialized;
    expect(garden.busy, isFalse);
    expect(garden.error, isNotNull);
    garden.navigate(GardenPage.signIn);
    expect(garden.page, GardenPage.signIn);
    preferences.pending.complete(20);
    await tester.pump();
    expect(garden.page, GardenPage.signIn);
    garden.dispose();
  });
  testWidgets(
    'opening stays visible until handoff and repeated opens coalesce',
    (tester) async {
      final fixture = FilesFixture();
      final file = await fixture.create(7, 0, 'movie.mp4', NodeKind.file);
      final controller = FileOpeningController();
      final handoff = Completer<void>();
      var calls = 0;
      Future<void> open() {
        calls++;
        return handoff.future;
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(body: FileOpeningStatus(controller: controller)),
        ),
      );
      final first = controller.run(file, open);
      final second = controller.run(file, open);
      await tester.pump();
      expect(calls, 1);
      expect(identical(first, second), isTrue);
      await tester.pump();
      expect(find.text('Opening movie.mp4'), findsNWidgets(2));
      expect(find.text('Checking drive connection'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      handoff.complete();
      await first;
      await tester.pump();
      expect(find.text('Opening movie.mp4'), findsNothing);
      controller.dispose();
      await fixture.events.close();
    },
  );

  testWidgets('an unresponsive native open times out and clears progress', (
    tester,
  ) async {
    final fixture = FilesFixture();
    final file = await fixture.create(7, 0, 'movie.mp4', NodeKind.file);
    final controller = FileOpeningController();
    final handoff = Completer<void>();
    final failed = expectLater(
      controller.run(file, () => handoff.future),
      throwsA(isA<TimeoutException>()),
    );
    await tester.pump(const Duration(minutes: 2));
    await failed;
    expect(controller.node, isNull);
    handoff.complete();
    await tester.pump();
    expect(controller.node, isNull);
    controller.dispose();
    await fixture.events.close();
  });

  testWidgets('the account menu still opens while a directory is loading', (
    tester,
  ) async {
    final fixture = FilesFixture();
    final files = FilesController(fixture)..busy = true;
    final garden =
        GardenController(TestGateway(), MemoryPreferences(), files: files)
          ..account = const AccountInfo(id: 'first', email: 'first@example.com')
          ..page = GardenPage.gardens;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: ProfileButton(controller: garden)),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(garden.page, GardenPage.settings);
    garden.dispose();
    files.dispose();
    await fixture.events.close();
  });
}

class PendingPreferences extends MemoryPreferences {
  final pending = Completer<int>();
  @override
  Future<int> readCacheLimit() => pending.future;
}
