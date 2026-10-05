import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_group.dart';
import 'drive_invitation_row.dart';

class DriveInvitationsGroup extends StatelessWidget {
  const DriveInvitationsGroup({
    super.key,
    required this.drive,
    required this.busy,
    required this.onResend,
    required this.onRevoke,
  });
  final DriveManagement drive;
  final bool busy;
  final void Function(DriveInvitation) onResend, onRevoke;

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      for (final invitation in drive.invitations)
        DriveInvitationRow(
          invitation: invitation,
          busy:
              busy ||
              (drive.drive.role != 'Owner' && invitation.role == 'Manager'),
          onResend: () => onResend(invitation),
          onRevoke: () => onRevoke(invitation),
        ),
    ],
  );
}
