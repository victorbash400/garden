import 'package:flutter/material.dart';

import '../../state/inbox_controller.dart';
import '../../ui/garden_colors.dart';
import 'inbox_row.dart';

class InboxConversationList extends StatelessWidget {
  const InboxConversationList({super.key, required this.controller});
  final InboxController controller;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 8, 0, 12),
    decoration: BoxDecoration(
      border: Border.all(color: GardenColors.of(context).border),
      borderRadius: BorderRadius.circular(14),
    ),
    clipBehavior: Clip.antiAlias,
    child: controller.entries.isEmpty
        ? const Center(child: Text('No conversations'))
        : ListView.builder(
            itemCount: controller.entries.length,
            itemBuilder: (_, index) {
              final entry = controller.entries[index];
              return InboxRow(
                entry: entry,
                user: controller.userId,
                selected: controller.selectedKey == InboxController.key(entry),
                onOpen: () => controller.select(entry),
              );
            },
          ),
  );
}
