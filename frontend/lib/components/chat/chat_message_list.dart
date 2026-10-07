import 'package:flutter/material.dart';

import '../scroll_edge.dart';
import '../../ui/garden_colors.dart';

import '../../state/chat_controller.dart';
import 'chat_message_row.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.controller,
    required this.onFile,
  });
  final ChatController controller;
  final ValueChanged<int> onFile;
  @override
  Widget build(BuildContext context) {
    final thread = controller.thread;
    final items = controller.messages
        .where(
          (m) => thread == null
              ? m.replyToId == null
              : m.id == thread.id || m.replyToId == thread.id,
        )
        .toList();
    final replyParents = controller.messages
        .map((message) => message.replyToId)
        .nonNulls
        .toSet();
    final hasOlder = thread == null
        ? controller.hasOlder
        : controller.threadHasOlder;
    return ScrollEdge(
      color: GardenColors.of(context).panel,
      child: NotificationListener<ScrollNotification>(
        onNotification: (event) {
          if (event.metrics.extentAfter < 80 &&
              hasOlder &&
              !controller.loading &&
              !controller.threadLoading) {
            controller.older();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          reverse: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final message = items[index];
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ChatMessageRow(
                  key: ValueKey(message.id),
                  message: message,
                  own: message.authorId == controller.userId,
                  showSender:
                      index == items.length - 1 ||
                      items[index + 1].authorId != message.authorId ||
                      message.createdAt
                              .difference(items[index + 1].createdAt)
                              .inMinutes >=
                          5,
                  hasReplies:
                      thread == null &&
                      message.replyToId == null &&
                      (message.hasReplies || replyParents.contains(message.id)),
                  username: controller.identities[message.authorId],
                  onFile: onFile,
                  onReply: () => controller.openThread(thread ?? message),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
