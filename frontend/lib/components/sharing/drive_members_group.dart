import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_group.dart';
import '../settings/settings_row.dart';
import '../settings/settings_inline_button.dart';
import 'drive_member_row.dart';
import 'ownership_transfer_dialog.dart';

class DriveMembersGroup extends StatelessWidget {
  const DriveMembersGroup({
    super.key,
    required this.drive,
    required this.actorId,
    required this.busy,
    required this.onInvite,
    required this.onAction,
  });
  final DriveManagement drive;
  final String actorId;
  final bool busy;
  final VoidCallback onInvite;
  final Future<void> Function(DriveMemberDetails, String) onAction;

  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      for (final member in drive.members)
        DriveMemberRow(
          member: member,
          actorId: actorId,
          actorRole: drive.drive.role,
          busy: busy,
          onAction: (role) async {
            if (role == 'transfer' &&
                !await confirmOwnershipTransfer(context, member.displayName)) {
              return;
            }
            await onAction(member, role);
          },
        ),
      if (drive.drive.role == 'Owner' || drive.drive.role == 'Manager')
        SettingsRow(
          label: 'Members',
          value: SettingsInlineButton(
            label: 'Invite',
            onPressed: busy ? null : onInvite,
          ),
        ),
    ],
  );
}
