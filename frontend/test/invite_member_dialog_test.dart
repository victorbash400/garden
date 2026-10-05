import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/sharing/invite_member_dialog.dart';
import 'package:garden_flutter/services/sharing/drive_sharing_service.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

class InviteService extends DriveSharingService {
  InviteService() : super(Client('http://localhost:8080/'));
  final result = Completer<DriveInvitation>();
  int calls = 0;
  String? recipient, permission;
  @override
  Future<DriveInvitation> invite(int drive, String email, String role) {
    calls++;
    recipient = email;
    permission = role;
    return result.future;
  }
}

void main() {
  testWidgets('empty invites are disabled and failure preserves the address', (
    tester,
  ) async {
    final service = InviteService();
    await tester.pumpWidget(
      MaterialApp(
        theme: GardenTheme.light,
        home: Scaffold(
          body: InviteMemberDialog(service: service, driveId: 1, owner: false),
        ),
      ),
    );
    final invite = find.widgetWithText(TextButton, 'Invite');
    expect(tester.widget<TextButton>(invite).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'reader@example.com');
    await tester.pump();
    expect(tester.widget<TextButton>(invite).onPressed, isNotNull);
    await tester.tap(find.widgetWithText(TextButton, 'Viewer'));
    await tester.pumpAndSettle();
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Manager'), findsNothing);
    await tester.tap(find.text('Editor'));
    await tester.pumpAndSettle();
    await tester.tap(invite);
    await tester.pump();
    expect(service.calls, 1);
    expect(service.recipient, 'reader@example.com');
    expect(service.permission, 'Editor');
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    service.result.completeError(GardenException(message: 'Already invited.'));
    await tester.pumpAndSettle();
    expect(find.text('Already invited.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'reader@example.com',
    );
    expect(tester.widget<TextButton>(invite).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
