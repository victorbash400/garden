import 'package:flutter/material.dart';

import '../files/toolbar_button.dart';
import '../settings/settings_inline_button.dart';
import '../system_icon.dart';
import '../chat/chat_drawer_button.dart';

class InboxToolbar extends StatelessWidget {
  const InboxToolbar({
    super.key,
    required this.invites,
    this.invitesUnread = 0,
    required this.onInvites,
    required this.onInbox,
    required this.onNew,
    required this.onDrawer,
  });
  final int invitesUnread;
  final bool invites;
  final VoidCallback onInvites, onInbox, onNew, onDrawer;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        ChatDrawerButton(open: false, onPressed: onDrawer),
        SettingsInlineButton(
          label: 'Inbox',
          primary: !invites,
          onPressed: onInbox,
        ),
        SettingsInlineButton(
          label: invitesUnread == 0 ? 'Invites' : 'Invites ($invitesUnread)',
          primary: invites,
          onPressed: onInvites,
        ),
        const Spacer(),
        if (!invites)
          ToolbarButton(
            tooltip: 'New conversation',
            icon: SystemIcons.squarePen,
            onPressed: onNew,
          ),
      ],
    ),
  );
}
