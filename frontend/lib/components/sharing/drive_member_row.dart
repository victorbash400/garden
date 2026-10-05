import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_row.dart';

class DriveMemberRow extends StatelessWidget {
  const DriveMemberRow({
    super.key,
    required this.member,
    required this.actorId,
    required this.actorRole,
    required this.busy,
    required this.onAction,
  });
  final DriveMemberDetails member;
  final String actorId, actorRole;
  final bool busy;
  final Future<void> Function(String) onAction;
  bool get manageable =>
      member.userId != actorId &&
      member.role != 'Owner' &&
      (actorRole == 'Owner' ||
          (actorRole == 'Manager' &&
              (member.role == 'Editor' || member.role == 'Viewer')));
  @override
  Widget build(BuildContext context) => SettingsRow(
    label: member.displayName,
    value: manageable
        ? PopupMenuButton<String>(
            tooltip: 'Member permission',
            enabled: !busy,
            popUpAnimationStyle: AnimationStyle.noAnimation,
            onSelected: onAction,
            itemBuilder: (_) => [
              for (final role in [
                'Viewer',
                'Editor',
                if (actorRole == 'Owner') 'Manager',
              ])
                CheckedPopupMenuItem(
                  value: role,
                  checked: member.role == role,
                  child: Text(role),
                ),
              if (actorRole == 'Owner')
                const PopupMenuItem(
                  value: 'transfer',
                  child: Text('Transfer ownership…'),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove member'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(member.role),
            ),
          )
        : Text(member.role),
  );
}
