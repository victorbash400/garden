import 'dart:typed_data';

import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/settings/account_security_controls.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/services/serverpod_gateway.dart';
import 'package:garden_flutter/state/account_security_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

class SecurityFixture extends AccountSecurityController {
  SecurityFixture() : super(ServerpodGateway('https://example.test/')) {
    configured = true;
    available = true;
    keys = [
      (
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
        createdAt: DateTime(2026, 10, 1),
        keyId: ByteData(1),
      ),
    ];
  }
  int removed = 0;
  int added = 0;
  @override
  Future<void> load() async {}
  @override
  Future<void> addPasskey(AccountInfo account) async {
    added++;
  }

  @override
  Future<void> removePasskey(UuidValue id) async {
    removed++;
  }

  @override
  Future<void> setTouchId(bool enabled, AccountInfo account) async {
    touchId = enabled;
    notifyListeners();
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  const account = AccountInfo(id: 'account', email: 'garden@example.com');
  testWidgets(
    'existing accounts can add keys, confirm removal and enable Touch ID',
    (tester) async {
      final security = SecurityFixture();
      await tester.pumpWidget(
        MaterialApp(
          theme: GardenTheme.light,
          home: Scaffold(
            body: AccountSecurityControls(
              controller: security,
              account: account,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Add passkey'));
      expect(security.added, 1);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(security.removed, 0);
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Remove').last);
      await tester.pumpAndSettle();
      expect(security.removed, 1);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(security.touchId, isTrue);
      security.gateway.dispose();
      security.dispose();
    },
  );
  testWidgets('incomplete Apple signing disables native enrollment visibly', (
    tester,
  ) async {
    final security = SecurityFixture()..configured = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: AccountSecurityControls(controller: security, account: account),
        ),
      ),
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Add passkey'))
          .onPressed,
      isNull,
    );
    expect(find.text('Apple signing setup required'), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    security.gateway.dispose();
    security.dispose();
  });
}
