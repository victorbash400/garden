import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import 'chat_message_bubble.dart';
import 'chat_sender.dart';

class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    super.key,
    required this.message,
    required this.onReply,
    required this.onFile,
    required this.showSender,
    required this.own,
    required this.hasReplies,
    this.username,
    this.groupEnd = true,
  });
  final DriveMessage message;
  final String? username;
  final VoidCallback onReply;
  final ValueChanged<int> onFile;
  final bool showSender, hasReplies, own, groupEnd;

  Future<void> menu(BuildContext context, Offset position) async {
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: const [
        PopupMenuItem(value: 'reply', child: Text('Reply in thread')),
      ],
    );
    if (choice == 'reply') onReply();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onSecondaryTapDown: (event) => menu(context, event.globalPosition),
    onLongPressStart: (event) => menu(context, event.globalPosition),
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, showSender ? 12 : 2, 16, 2),
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: own ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * .82),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: own
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (showSender)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                    child: ChatSender(
                      username: own ? '' : username ?? message.username,
                      time: message.createdAt.toLocal(),
                    ),
                  ),
                ChatMessageBubble(
                  message: message,
                  own: own,
                  hasReplies: hasReplies,
                  groupStart: showSender,
                  groupEnd: groupEnd,
                  onReply: onReply,
                  onFile: onFile,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
