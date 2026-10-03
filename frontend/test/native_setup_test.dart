import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/settings/finder_setup_row.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/finder_updates.dart';
import 'package:garden_flutter/native/mac_finder_updates.dart';
import 'package:garden_flutter/native/system_setup.dart';
import 'package:garden_flutter/state/native_setup_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';

import 'files_gateway_fixture.dart';
import 'widget_test.dart' show TestFinder, TestGateway, MemoryPreferences;

class TestSystem implements SystemSetup {
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
    'background status uses stream readiness and disconnects visibly',
    () async {
      final gateway = FilesFixture();
      final finder = TestFinder();
      final system = TestSystem();
      final updates = MacFinderUpdates(gateway, finder, system);
      const account = AccountInfo(id: 'account', email: 'test@example.com');
      const drive = GardenInfo(id: 1, name: 'Work', role: 'Owner', members: 1);
      await updates.sync(account, [drive]);
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.running);
      expect(system.active, isTrue);
      gateway.events.addError(StateError('Connection lost'));
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.disconnected);
      expect(updates.error, contains('Connection lost'));
      await updates.sync(account, [drive]);
      await Future<void>.delayed(Duration.zero);
      expect(updates.state, FinderUpdateState.running);
      await updates.close();
      expect(system.active, isFalse);
      expect(updates.state, FinderUpdateState.idle);
      expect(gateway.events.hasListener, isFalse);
      updates.dispose();
      await gateway.events.close();
    },
  );
}
