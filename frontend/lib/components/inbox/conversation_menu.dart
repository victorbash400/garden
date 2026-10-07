import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import 'conversation_action_dialog.dart';
import '../system_icon.dart';
import '../files/toolbar_button.dart';

class ConversationMenu extends StatelessWidget {
  const ConversationMenu({super.key, required this.chat});
  final ChatController chat;
  @override
  Widget build(BuildContext context) {
    final value = chat.conversation;
    if (value == null) return const SizedBox.shrink();
    final creator = value.conversation.creatorId == chat.userId;
    return PopupMenuButton<String>(
      tooltip: 'Conversation options',
      padding: EdgeInsets.zero,
      style: ToolbarButton.style(context),
      icon: const SystemIcon(SystemIcons.ellipsis, size: 17),
      onSelected: (action) => showDialog(
        context: context,
        builder: (_) => ConversationActionDialog(chat: chat, action: action),
      ),
      itemBuilder: (_) => [
        if (creator)
          const PopupMenuItem(value: 'rename', child: Text('Rename')),
        PopupMenuItem(
          value: creator ? 'delete' : 'leave',
          child: Text(creator ? 'Delete conversation' : 'Leave conversation'),
        ),
      ],
    );
  }
}
