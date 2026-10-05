import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/sharing/notification_bell.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/state/sharing/notification_controller.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

class TestConnectivity extends ConnectivityMonitor {
  void change(bool connected) => notifyListeners(connected);
}

class NotificationFixture extends DriveSharingService {
  NotificationFixture() : super(Client('http://localhost:8080/')) {
    client.connectivityMonitor = connectivity;
  }
  final connectivity = TestConnectivity();
  int watches = 0;
  final events = StreamController<AccountNotification>.broadcast();
  final read = Completer<void>();
  List<AccountNotification> initial = [];
  @override
  Future<List<AccountNotification>> notifications() async => initial;
  @override
  Stream<AccountNotification> watch(int cursor) {
    watches++;
    return events.stream;
  }

  @override
  Future<void> markRead(int id) => read.future;
}

AccountNotification notice(int id) => AccountNotification(
  id: id,
  recipientEmail: 'recipient@example.com',
  kind: 'invitation',
  title: 'Shared drive',
  createdAt: DateTime.now().toUtc(),
);

class DelayedSharingGateway extends TestGateway implements SharingGateway {
  @override
  final NotificationFixture sharing = NotificationFixture();
  final listing = Completer<List<GardenInfo>>();
  @override
  Future<List<GardenInfo>> listGardens() => listing.future;
}

void main() {
  test(
    'an in-flight access refresh cannot update a closed account window',
    () async {
      final gateway = DelayedSharingGateway();
      final controller = GardenController(gateway, MemoryPreferences())
        ..account = const AccountInfo(id: 'owner', email: 'owner@example.com');
      await controller.notifications!.start();
      controller.dispose();
      gateway.listing.complete([
        const GardenInfo(id: 1, name: 'Shared', role: 'Owner', members: 1),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(controller.gardens, isEmpty);
      await gateway.sharing.events.close();
    },
  );
  test(
    'overlapping starts subscribe once and network restoration replays data',
    () async {
      final service = NotificationFixture()..initial = [notice(1)];
      final controller = NotificationController(service);
      await Future.wait([controller.start(), controller.start()]);
      expect(service.watches, 1);
      service.connectivity.change(false);
      service.initial = [notice(1), notice(2)];
      service.connectivity.change(true);
      await Future<void>.delayed(Duration.zero);
      expect(service.watches, 2);
      expect(controller.items.map((item) => item.id), [2, 1]);
      await controller.close();
      service.connectivity.change(false);
      service.connectivity.change(true);
      await Future<void>.delayed(Duration.zero);
      expect(service.watches, 2);
      controller.dispose();
      await service.events.close();
    },
  );

  test('account controllers do not share notifications and closed reads cannot restore data', () async {
    final serviceA = NotificationFixture()..initial = [notice(1)];
    final serviceB = NotificationFixture()..initial = [notice(2)];
    final a = NotificationController(serviceA);
    final b = NotificationController(serviceB);
    await a.start();
    await b.start();
    expect(a.items.single.id, 1);
    expect(b.items.single.id, 2);
    final reading = a.markRead(a.items.single);
    await a.close();
    serviceA.read.complete();
    await reading;
    expect(a.items, isEmpty);
    expect(b.items.single.id, 2);
    a.dispose();
    b.dispose();
    await serviceA.events.close();
    await serviceB.events.close();
  });

  testWidgets('bell opens Notifications from the file browser', (tester) async {
    final controller = GardenController(TestGateway(), MemoryPreferences())
      ..page = GardenPage.files;
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: NotificationBell(controller: controller)),
      ),
    );
    await tester.tap(find.byTooltip('Notifications'));
    expect(controller.page, GardenPage.settings);
    expect(controller.settingsSection, SettingsSection.notifications);
    controller.dispose();
  });
}
