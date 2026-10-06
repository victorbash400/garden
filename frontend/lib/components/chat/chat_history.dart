import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import '../../ui/garden_colors.dart';
import '../list_row.dart';
import '../system_icon.dart';

class ChatHistory extends StatelessWidget {
  const ChatHistory({
    super.key,
    required this.controller,
    required this.driveName,
    required this.onNew,
  });
  final ChatController controller;
  final String driveName;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final items = controller.conversations;
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: GardenColors.of(context).sidebar,
        border: Border(
          right: BorderSide(color: GardenColors.of(context).border),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListRow(
            onTap: controller.sending ? null : onNew,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  SystemIcon(SystemIcons.squarePen, size: 16),
                  SizedBox(width: 8),
                  Text('New chat', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListRow(
            selected: controller.conversation == null,
            onTap: () => controller.selectConversation(null),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Text(
                'Everyone in $driveName',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (event) {
                if (event.metrics.extentAfter < 80 &&
                    controller.historyHasOlder &&
                    !controller.historyLoading) {
                  controller.loadConversations(older: true);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final item = items[index];
                  final names = item.members
                      .where((member) => member.userId != controller.userId)
                      .map((member) => member.username)
                      .join(', ');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: ListRow(
                      selected:
                          controller.conversation?.conversation.id ==
                          item.conversation.id,
                      onTap: () => controller.selectConversation(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 9,
                        ),
                        child: Text(
                          item.conversation.title.isEmpty
                              ? names
                              : item.conversation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
