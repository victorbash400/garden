import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

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
    final messages = controller.messages;
    final items = messages
        .where(
          (m) => thread == null
              ? m.replyToId == null
              : m.id == thread.id || m.replyToId == thread.id,
        )
        .toList();
    final replyParents = messages
        .map((message) => message.replyToId)
        .nonNulls
        .toSet();
    final hasOlder = thread == null
        ? controller.hasOlder
        : controller.threadHasOlder;
    final indices = {for (var i = 0; i < items.length; i++) items[i].id!: i};
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          reverse: true,
          itemCount: items.length,
          findChildIndexCallback: (key) =>
              key is ValueKey<int> ? indices[key.value] : null,
          itemBuilder: (context, index) {
            final message = items[index];
            return Align(
              key: ValueKey(message.id!),
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ChatMessageRow(
                  message: message,
                  own: message.authorId == controller.userId,
                  showSender:
                      index == items.length - 1 ||
                      !_sameGroup(message, items[index + 1]),
                  groupEnd:
                      index == 0 || !_sameGroup(items[index - 1], message),
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

bool _sameGroup(DriveMessage newer, DriveMessage older) {
  final current = newer.createdAt.toLocal();
  final previous = older.createdAt.toLocal();
  return newer.authorId == older.authorId &&
      current.year == previous.year &&
      current.month == previous.month &&
      current.day == previous.day &&
      current.difference(previous).abs() < const Duration(minutes: 5);
}
