import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/components/finder_status_observer.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/native/account_window.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/state/garden_controller.dart';

import 'notifications_test.dart' show ReconnectingNotificationFixture, notice;
import 'widget_test.dart' show TestGateway, MemoryPreferences;

class FocusGateway extends TestGateway implements SharingGateway {
  @override
  final ReconnectingNotificationFixture sharing =
      ReconnectingNotificationFixture();
}

void main() {
  testWidgets('account window focus recovers a closed notification stream', (
    tester,
  ) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(AccountWindow.channel, (call) async {
      if (call.method == 'initialize') {
        return {
          'id': 'second',
          'active': false,
          'windows': <Object?>[],
          'build': {'ready': false, 'restarting': false},
        };
      }
      return null;
    });
    final window = AccountWindow();
    await window.initialize();
    final gateway = FocusGateway();
    final controller = GardenController(
      gateway,
      MemoryPreferences(),
      accountWindow: window,
    )..account = const AccountInfo(id: 'reader', email: 'reader@example.com');
    await controller.notifications!.start();
    await tester.pumpWidget(
      FinderStatusObserver(controller: controller, child: const SizedBox()),
    );

    Future<void> focus(bool active) => messenger.handlePlatformMessage(
      AccountWindow.channel.name,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall('active', active),
      ),
      (response) {
        if (response != null) {
          const StandardMethodCodec().decodeEnvelope(response);
        }
      },
    );

    await gateway.sharing.events.close();
    expect(controller.notifications!.error, isNotNull);
    gateway.sharing.initial = [notice(1)];
    await focus(false);
    await tester.pump();
    expect(gateway.sharing.watches, 1);
    await focus(true);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(controller.notifications!.loading, isFalse);
    expect(gateway.sharing.watches, 2);
    expect(controller.notifications!.error, isNull);
    expect(controller.notifications!.items.single.id, 1);
    await focus(true);
    await tester.pump();
    expect(gateway.sharing.watches, 2);

    await tester.pumpWidget(const SizedBox());
    await gateway.sharing.resumedEvents.close();
    await focus(true);
    await tester.pump();
    expect(gateway.sharing.watches, 2);
    controller.dispose();
    window.dispose();
    messenger.setMockMethodCallHandler(AccountWindow.channel, null);
  });
}
