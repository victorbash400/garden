import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:garden_flutter/ui/garden_theme.dart';
import 'package:garden_flutter/views/drives_settings.dart';

import 'widget_test.dart' show TestGateway, MemoryPreferences;

class StatusService extends DriveSharingService {
  StatusService() : super(Client('http://localhost:8080/'));
  final events = StreamController<AccountNotification>.broadcast();
  bool declined = false;
  int loads = 0;
  @override
  Stream<AccountNotification> watch(int cursor) => events.stream;
  @override
  Future<List<AccountNotification>> notifications() async => [];
  @override
  Future<DriveManagement> management(int drive) async {
    loads++;
    final now = DateTime.now().toUtc();
    return DriveManagement(
      drive: GardenSummary(
        id: drive,
        name: 'Shared',
        role: 'Owner',
        members: 1,
      ),
      logicalBytes: 0,
      fileCount: 0,
      folderCount: 0,
      members: [],
      invitations: [
        DriveInvitation(
          id: 1,
          gardenId: drive,
          inviterId: 'owner',
          recipientEmail: 'reader@example.com',
          role: 'Viewer',
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          declinedAt: declined ? now : null,
        ),
      ],
    );
  }
}

class StatusGateway extends TestGateway implements SharingGateway {
  @override
  final StatusService sharing = StatusService();
  @override
  Future<List<GardenInfo>> listGardens() async => [
    const GardenInfo(id: 1, name: 'Shared', role: 'Owner', members: 1),
  ];
}

void main() {
  testWidgets('inviter status events refresh open management actions', (
    tester,
  ) async {
    final gateway = StatusGateway();
    final controller = GardenController(gateway, MemoryPreferences())
      ..account = const AccountInfo(id: 'owner', email: 'owner@example.com')
      ..gardens = [
        const GardenInfo(id: 1, name: 'Shared', role: 'Owner', members: 1),
      ];
    await controller.notifications!.start();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(body: DrivesSettings(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Resend'), findsOneWidget);
    gateway.sharing.declined = true;
    gateway.sharing.events.add(
      AccountNotification(
        id: 1,
        recipientEmail: 'owner@example.com',
        gardenId: 1,
        kind: 'invitationUpdated',
        title: 'Shared · Invitation declined',
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Viewer · Declined'), findsOneWidget);
    expect(find.text('Resend'), findsNothing);
    expect(find.text('Revoke'), findsNothing);
    expect(gateway.sharing.loads, 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    await gateway.sharing.events.close();
  });
}
