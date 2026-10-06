import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import '../system_icon.dart';
import '../files/toolbar_button.dart';
import 'chat_audience_dialog.dart';
import 'chat_drawer_button.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.controller,
    required this.driveName,
  });
  final ChatController controller;
  final String driveName;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    child: Row(
      children: [
        ChatDrawerButton(
          open: controller.historyVisible,
          onPressed: controller.showHistory,
        ),
        if (controller.thread != null)
          ToolbarButton(
            tooltip: 'Back to conversation',
            icon: SystemIcons.arrowLeft,
            onPressed: () => controller.openThread(null),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            controller.audience(driveName),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        ToolbarButton(
          tooltip: 'Who can see this chat',
          icon: SystemIcons.userRound,
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ChatAudienceDialog(
              controller: controller,
              driveName: driveName,
            ),
          ),
        ),
        ToolbarButton(
          tooltip: 'Close chat',
          icon: SystemIcons.x,
          onPressed: controller.toggle,
        ),
      ],
    ),
  );
}
