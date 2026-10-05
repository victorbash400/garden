import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/notifications_settings.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

class InvitationService extends DriveSharingService {
  InvitationService() : super(Client('http://localhost:8080/'));
  final events = StreamController<AccountNotification>.broadcast();
  final item = AccountNotification(
    id: 1,
    recipientEmail: 'reader@example.com',
    kind: 'invitation',
    title: 'Shared drive',
    gardenId: 2,
    invitationId: 1,
    createdAt: DateTime.now().toUtc(),
  );
  final invitation = DriveInvitation(
    id: 1,
    gardenId: 2,
    inviterId: 'owner',
    recipientEmail: 'reader@example.com',
    role: 'Viewer',
    createdAt: DateTime.now().toUtc(),
    expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
  );
  bool accepted = false;
  bool failAccept = false;
  @override
  Future<List<AccountNotification>> notifications() async => [item];
  @override
  Stream<AccountNotification> watch(int cursor) => events.stream;
  @override
  Future<List<DriveInvitation>> received() async => [
    accepted
        ? invitation.copyWith(acceptedAt: DateTime.now().toUtc())
        : invitation,
  ];
  @override
  Future<void> accept(int id) async {
    if (failAccept) throw StateError('Invitation has expired.');
    accepted = true;
  }

  @override
  Future<void> markRead(int id) async {}
}

class InvitationGateway extends TestGateway implements SharingGateway {
  @override
  final InvitationService sharing = InvitationService();
  @override
  Future<List<GardenInfo>> listGardens() async => sharing.accepted
      ? [const GardenInfo(id: 2, name: 'Shared', role: 'Viewer', members: 2)]
      : [];
}

void main() {
  for (final fail in [false, true]) {
    testWidgets(
      fail
          ? 'acceptance errors keep invitation actions available'
          : 'accepting refreshes drives and stays in Notifications',
      (tester) async {
        final gateway = InvitationGateway();
        gateway.sharing.failAccept = fail;
        final controller = GardenController(gateway, MemoryPreferences())
          ..account = const AccountInfo(
            id: 'reader',
            email: 'reader@example.com',
          )
          ..page = GardenPage.settings
          ..settingsSection = SettingsSection.notifications;
        await controller.notifications!.start();
        await tester.pumpWidget(
          MaterialApp(
            theme: GardenTheme.light,
            home: Scaffold(
              body: AnimatedBuilder(
                animation: controller,
                builder: (_, _) =>
                    NotificationsSettings(controller: controller),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();
        expect(controller.page, GardenPage.settings);
        expect(controller.settingsSection, SettingsSection.notifications);
        if (fail) {
          expect(find.text('Invitation has expired.'), findsOneWidget);
          expect(find.text('Accept'), findsOneWidget);
          expect(controller.gardens, isEmpty);
        } else {
          expect(controller.gardens.single.role, 'Viewer');
          expect(find.text('Accepted'), findsOneWidget);
          expect(find.text('Accept'), findsNothing);
          expect(controller.notifications!.unread, 0);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
        await gateway.sharing.events.close();
      },
    );
  }
}
