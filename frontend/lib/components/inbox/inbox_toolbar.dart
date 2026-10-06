import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../files/toolbar_button.dart';
import '../files/toolbar_group.dart';
import '../system_icon.dart';

class InboxToolbar extends StatelessWidget {
  const InboxToolbar({
    super.key,
    required this.invites,
    this.invitesUnread = 0,
    required this.onInvites,
    required this.onInbox,
  });
  final int invitesUnread;
  final bool invites;
  final VoidCallback onInvites, onInbox;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: ToolbarGroup(
        children: [
          ToolbarButton(
            tooltip: 'Inbox',
            icon: SystemIcons.inbox,
            selected: !invites,
            onPressed: onInbox,
          ),
          Badge(
            isLabelVisible: invitesUnread > 0,
            backgroundColor: GardenColors.of(context).accent,
            smallSize: 6,
            offset: const Offset(-7, 7),
            child: ToolbarButton(
              tooltip: 'Invites',
              icon: SystemIcons.mail,
              selected: invites,
              onPressed: onInvites,
            ),
          ),
        ],
      ),
    ),
  );
}
