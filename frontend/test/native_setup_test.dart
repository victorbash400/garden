import 'package:garden_flutter/ui/garden_theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/finder_setup_row.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/finder_updates.dart';
import 'package:garden_flutter/native/finder_status.dart';
import 'package:garden_flutter/native/mac_finder_updates.dart';
import 'package:garden_flutter/native/system_setup.dart';
import 'package:garden_flutter/state/native_setup_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';

import 'widget_test.dart' show TestFinder, TestGateway, MemoryPreferences;

class TestSystem implements SystemSetup {
  @override
  Stream<void> get wakeEvents => const Stream.empty();
  bool active = false;
  bool settingsOpened = false;
  LoginItemState login = LoginItemState.disabled;
  @override
  Future<SystemSetupStatus> status() async =>
      SystemSetupStatus(finderAvailable: true, launchAtLogin: login);
  @override
  Future<SystemSetupStatus> setLaunchAtLogin(bool enabled) async {
    login = enabled ? LoginItemState.requiresApproval : LoginItemState.disabled;
    return status();
  }

  @override
  Future<void> openLoginSettings() async {
    settingsOpened = true;
  }

  @override
  Future<void> setBackgroundActive(bool enabled) async {
    active = enabled;
  }
}

void main() {
  test(
    'optional setup does not create alerts, broken connections do',
    () async {
      final system = TestSystem()..login = LoginItemState.notFound;
      final setup = NativeSetupController(system);
      await setup.refresh();
      expect(setup.needsAttention, isFalse);
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        finder: TestFinder(),
        nativeSetup: setup,
      );
      controller.account = const AccountInfo(
        id: 'account',
        email: 'test@example.com',
      );
      controller.serviceAvailable = true;
      controller.gardens = [
        const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
      ];
      expect(controller.needsFinderAttention, isFalse);
      controller.finderStatus = const FinderStatus(
        registered: {1},
        disabled: {1},
      );
      expect(controller.needsFinderAttention, isFalse);
      controller.finderStatus = const FinderStatus(
        registered: {1},
        disconnected: {1},
      );
      expect(controller.needsFinderAttention, isTrue);
      controller.finderStatus = const FinderStatus(
        registered: {1},
        enabled: {1},
      );
      expect(controller.needsFinderAttention, isFalse);
      controller.serviceAvailable = false;
      expect(controller.needsFinderAttention, isTrue);
      controller.serviceAvailable = true;
      controller.finderUpdateError(StateError('Finder connection failed'));
      expect(controller.needsFinderAttention, isTrue);
      controller.dispose();
      setup.dispose();
    },
  );

  test(
    'wake reconnects local drive status without a second server stream',
    () async {
      final finder = TestFinder();
      var subscriptions = 0;
      final streams = <StreamController<FinderStatus>>[];
      final updates = MacFinderUpdates(
        watch: (account, drives) {
          subscriptions++;
          final stream = StreamController<FinderStatus>();
          stream.add(const FinderStatus(registered: {1}, enabled: {1}));
          streams.add(stream);
          return stream.stream;
        },
      );
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        finder: finder,
        finderUpdates: updates,
      );
      controller.account = const AccountInfo(
        id: 'account',
        email: 'test@example.com',
      );
      controller.gardens = [
        const GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1),
      ];
      await controller.handleSystemWake();
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.running);
      final calls = subscriptions;
      await controller.handleSystemWake();
      await Future<void>.delayed(Duration.zero);
      expect(subscriptions, calls + 1);
      expect(updates.state, FinderUpdateState.running);
      expect(updates.error, isNull);
      controller.dispose();
      await updates.close();
      updates.dispose();
      for (final stream in streams) {
        await stream.close();
      }
    },
  );

  testWidgets('approval remains unverified before the first drive', (
    tester,
  ) async {
    final setup = NativeSetupController(TestSystem());
    await setup.refresh();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      finder: TestFinder(),
      nativeSetup: setup,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: FinderSetupRow(controller: controller)),
      ),
    );
    expect(find.text('Approval not checked'), findsOneWidget);
    expect(find.text('Connected'), findsNothing);
    controller.dispose();
    setup.dispose();
  });

  test(
    'login registration reports pending approval and refresh reads OS changes',
    () async {
      final system = TestSystem();
      final setup = NativeSetupController(system);
      await setup.refresh();
      expect(setup.status!.finderAvailable, isTrue);
      expect(setup.needsAttention, isFalse);
      await setup.setLaunchAtLogin(true);
      expect(setup.status!.launchAtLogin, LoginItemState.requiresApproval);
      expect(setup.needsAttention, isTrue);
      await setup.openLoginSettings();
      expect(system.settingsOpened, isTrue);
      system.login = LoginItemState.enabled;
      await setup.refresh();
      expect(setup.needsAttention, isFalse);
      await setup.setLaunchAtLogin(false);
      expect(setup.status!.launchAtLogin, LoginItemState.disabled);
      setup.dispose();
    },
  );

  test(
    'helper status events report readiness and disconnect visibly',
    () async {
      final events = StreamController<FinderStatus>.broadcast();
      final updates = MacFinderUpdates(
        watch: (account, drives) => events.stream,
      );
      const account = AccountInfo(id: 'account', email: 'test@example.com');
      const drive = GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1);
      await updates.sync(account, [drive]);
      events.add(const FinderStatus(registered: {1}, enabled: {1}));
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.running);
      expect(updates.status?.enabled, {1});
      events.add(const FinderStatus(registered: {1}, disconnected: {1}));
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.disconnected);
      expect(updates.status?.disconnected, {1});
      events.addError(StateError('Connection lost'));
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.disconnected);
      expect(updates.error, contains('Connection lost'));
      await updates.sync(account, [drive]);
      events.add(const FinderStatus(registered: {1}, enabled: {1}));
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.running);
      await updates.close();
      expect(updates.state, FinderUpdateState.idle);
      expect(events.hasListener, isFalse);
      updates.dispose();
      await events.close();
    },
  );
}
