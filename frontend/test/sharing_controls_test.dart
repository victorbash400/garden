import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/components/sharing/drive_member_row.dart';
import 'package:garden_flutter/components/sharing/drive_invitation_row.dart';
import 'package:garden_flutter/components/sharing/drive_usage_group.dart';
import 'package:garden_flutter/ui/garden_theme.dart';

Widget host(Widget child) => MaterialApp(
  theme: GardenTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 740, child: child)),
  ),
);

void main() {
  testWidgets(
    'Manager can manage Viewer but cannot promote to Manager or transfer ownership',
    (tester) async {
      String? selected;
      await tester.pumpWidget(
        host(
          DriveMemberRow(
            member: DriveMemberDetails(
              userId: 'viewer',
              role: 'Viewer',
              displayName: 'Reader',
            ),
            actorId: 'manager',
            actorRole: 'Manager',
            busy: false,
            onAction: (value) async => selected = value,
          ),
        ),
      );
      await tester.tap(find.byTooltip('Member permission'));
      await tester.pumpAndSettle();
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Manager'), findsNothing);
      expect(find.text('Transfer ownership…'), findsNothing);
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<String>, 'Editor'),
      );
      await tester.pumpAndSettle();
      expect(selected, 'Editor');
      await tester.pumpWidget(
        host(
          DriveMemberRow(
            member: DriveMemberDetails(
              userId: 'owner',
              role: 'Owner',
              displayName: 'Owner account',
            ),
            actorId: 'manager',
            actorRole: 'Manager',
            busy: false,
            onAction: (_) async {},
          ),
        ),
      );
      expect(find.byTooltip('Member permission'), findsNothing);
    },
  );

  testWidgets(
    'Invitation delivery errors stay in the row and resend and revoke work',
    (tester) async {
      var resent = 0;
      var revoked = 0;
      final invitation = DriveInvitation(
        id: 1,
        gardenId: 1,
        inviterId: 'owner',
        recipientEmail: 'reader@example.com',
        role: 'Viewer',
        createdAt: DateTime.now().toUtc(),
        expiresAt: DateTime.now().toUtc().add(const Duration(days: 7)),
        deliveryStatus: 'failed',
        deliveryError: 'Email could not be sent.',
      );
      await tester.pumpWidget(
        host(
          DriveInvitationRow(
            invitation: invitation,
            busy: false,
            onResend: () => resent++,
            onRevoke: () => revoked++,
          ),
        ),
      );
      expect(find.text('Email could not be sent.'), findsOneWidget);
      await tester.tap(find.text('Resend'));
      await tester.tap(find.text('Revoke'));
      expect(resent, 1);
      expect(revoked, 1);
      await tester.pumpWidget(
        host(
          DriveInvitationRow(
            invitation: invitation.copyWith(revokedAt: DateTime.now().toUtc()),
            busy: false,
            onResend: () => resent++,
            onRevoke: () => revoked++,
          ),
        ),
      );
      expect(find.text('Resend'), findsNothing);
      expect(find.text('Revoke'), findsNothing);
      expect(find.text('Viewer · Revoked'), findsOneWidget);
    },
  );

  testWidgets('Cloud usage keeps small file sizes visible', (tester) async {
    await tester.pumpWidget(
      host(
        DriveUsageGroup(
          drive: DriveManagement(
            drive: GardenSummary(
              id: 1,
              name: 'Shared',
              role: 'Viewer',
              members: 2,
            ),
            logicalBytes: 29,
            fileCount: 1,
            folderCount: 0,
            members: [],
            invitations: [],
          ),
        ),
      ),
    );
    expect(find.text('29 B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
