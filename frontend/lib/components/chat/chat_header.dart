import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import '../system_icon.dart';
import '../files/toolbar_button.dart';
import '../files/toolbar_item_transition.dart';
import 'chat_audience_dialog.dart';
import 'chat_drawer_button.dart';
import '../inbox/conversation_menu.dart';
import '../inbox/conversation_avatar.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.controller,
    required this.driveName,
    this.showHistory = true,
  });
  final bool showHistory;
  final ChatController controller;
  final String driveName;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    child: Row(
      children: [
        if (showHistory)
          ChatDrawerButton(
            open: controller.historyVisible,
            onPressed: controller.showHistory,
          ),
        ToolbarItemTransition(
          child: controller.thread != null
              ? ToolbarButton(
                  tooltip: 'Back to conversation',
                  icon: SystemIcons.arrowLeft,
                  onPressed: () => controller.openThread(null),
                )
              : null,
        ),
        if (!showHistory)
          ConversationAvatar(
            size: 28,
            group:
                controller.conversation == null ||
                controller.conversation!.members.length > 2,
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            controller.audience(driveName),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        ConversationMenu(chat: controller),
        ToolbarButton(
          tooltip: 'Who can see this conversation',
          icon: SystemIcons.users,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ChatAudienceDialog(
              controller: controller,
              driveName: driveName,
            ),
          ),
        ),
        ToolbarButton(
          tooltip: 'Close conversation',
          icon: SystemIcons.x,
          onPressed: controller.toggle,
        ),
      ],
    ),
  );
}
