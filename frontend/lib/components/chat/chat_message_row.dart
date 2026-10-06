import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../ui/garden_colors.dart';
import '../file_icon.dart';
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
  });
  final DriveMessage message;
  final String? username;
  final VoidCallback onReply;
  final ValueChanged<int> onFile;
  final bool showSender, hasReplies, own;

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
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    final name = username ?? message.username;
    return GestureDetector(
      onSecondaryTapDown: (event) => menu(context, event.globalPosition),
      onLongPressStart: (event) => menu(context, event.globalPosition),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, showSender ? 16 : 2, 24, 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!own) ...[
              SizedBox(
                width: 30,
                child: showSender
                    ? Container(
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.hover,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          name.characters.first,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Align(
                alignment: own ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: own ? colors.hover : colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSender)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: ChatSender(
                            username: name,
                            time: message.createdAt.toLocal(),
                          ),
                        ),
                      if (message.text.isNotEmpty)
                        SelectableText(
                          message.text,
                          textWidthBasis: TextWidthBasis.longestLine,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      if (message.nodeId != null)
                        TextButton.icon(
                          onPressed: () => onFile(message.nodeId!),
                          icon: const FileIcon(size: 18),
                          label: Text(
                            message.nodeName!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      if (hasReplies)
                        TextButton(
                          onPressed: onReply,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 26),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View thread',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (own) ...[
              SizedBox(
                width: 30,
                child: showSender
                    ? Container(
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.hover,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          name.characters.first,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}
