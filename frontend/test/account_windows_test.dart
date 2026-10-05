import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/native/account_window.dart';
import 'package:garden_flutter/native/window_menu_delegate.dart';
import 'package:garden_flutter/services/serverpod_gateway.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_app.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'widget_test.dart' show TestGateway, TestFinder, MemoryPreferences;

class CountingFinder extends TestFinder {
  int signOutCalls = 0;
  @override
  Future<void> signOut(AccountInfo account) async {
    signOutCalls++;
    await super.signOut(account);
  }
}

class AccountWindowFixture extends AccountWindow {
  bool lastWindow = true;
  int opened = 0;
  AccountInfo? account;
  @override
  Future<void> open() async {
    opened++;
  }

  @override
  Future<void> setAccount(AccountInfo value) async {
    account = value;
  }

  @override
  Future<bool> releaseAccount() async {
    account = null;
    return lastWindow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'saved login metadata is isolated by window and preserves main keys',
    () async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final first = ServerpodGateway('https://example.test/');
      final second = ServerpodGateway('https://example.test/', windowId: 'two');
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      expect(first.savedEmailKey, 'garden.savedEmail.https://example.test/');
      await first.preferences.setString(
        first.savedEmailKey,
        'alice@example.test',
      );
      await second.preferences.setString(
        second.savedEmailKey,
        'bob@example.test',
      );
      await second.preferences.setBool(second.touchIdKey, true);
      expect(await first.savedLogin(), 'alice@example.test');
      expect(await second.savedLogin(), 'bob@example.test');
      expect(await first.preferences.getBool(first.touchIdKey), isNull);
    },
  );

  test(
    'sign-out keeps Finder when another window uses the same account',
    () async {
      final window = AccountWindowFixture()..lastWindow = false;
      final finder = CountingFinder();
      final controller = GardenController(
        TestGateway(),
        MemoryPreferences(),
        finder: finder,
        accountWindow: window,
      );
      await controller.signIn('alice@example.test', 'password');
      await controller.signOut();
      expect(finder.signOutCalls, 0);
      expect(controller.account, isNull);
      expect(window.account, isNull);
    },
  );

  testWidgets('profile menu opens settings and a new account window', (
    tester,
  ) async {
    final window = AccountWindowFixture();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      accountWindow: window,
    );
    await controller.signIn('alice@example.test', 'password');
    await tester.pumpWidget(GardenApp(controller: controller));
    expect(find.text('Settings'), findsNothing);
    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New account window'));
    await tester.pumpAndSettle();
    expect(window.opened, 1);
    expect(controller.account!.email, 'alice@example.test');
    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(controller.page, GardenPage.settings);
    expect(find.byTooltip('Account menu'), findsOneWidget);
  });

  test('background windows do not overwrite the focused window menu', () async {
    final calls = <MethodCall>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.menu, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.menu, null),
    );
    final delegate = WindowMenuDelegate();
    delegate.setMenus([PlatformMenuItem(label: 'Alice', onSelected: () {})]);
    expect(calls, isEmpty);
    delegate.setActive(true);
    expect(calls.length, 1);
    delegate.setActive(false);
    delegate.setMenus([PlatformMenuItem(label: 'Bob', onSelected: () {})]);
    expect(calls.length, 1);
    delegate.setActive(true);
    expect(calls.length, 2);
    expect(calls.last.arguments['0'].first['label'], 'Bob');
  });
}
