import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/inbox_controller.dart';
import '../../ui/garden_colors.dart';
import '../list_row.dart';
import 'conversation_avatar.dart';

class InboxRow extends StatelessWidget {
  const InboxRow({
    super.key,
    required this.entry,
    required this.user,
    required this.selected,
    required this.onOpen,
  });
  final InboxEntry entry;
  final String user;
  final bool selected;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return ListRow(
      selected: selected,
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            ConversationAvatar(
              group: entry.members.length > 2 || entry.conversationId == null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    InboxController.label(entry, user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: (entry.unreadCount > 0 || entry.isNew)
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.latestText.isEmpty
                        ? entry.driveName
                        : entry.latestText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: colors.secondary),
                  ),
                ],
              ),
            ),
            if ((entry.unreadCount > 0 || entry.isNew))
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Badge(
                  backgroundColor: colors.accent,
                  textColor: colors.onAccent,
                  label: Text(
                    '${entry.unreadCount > 0 ? entry.unreadCount : 1}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
