import 'package:flutter/material.dart';

import '../../state/inbox_controller.dart';
import '../../ui/garden_colors.dart';
import '../scroll_edge.dart';
import 'inbox_row.dart';

class InboxConversationList extends StatelessWidget {
  const InboxConversationList({
    super.key,
    required this.controller,
    this.onSelected,
  });
  final InboxController controller;
  final VoidCallback? onSelected;
  @override
  Widget build(BuildContext context) => controller.entries.isEmpty
      ? const Center(child: Text('No conversations'))
      : ScrollEdge(
          color: GardenColors.of(context).sidebar,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            itemCount: controller.entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (_, index) {
              final entry = controller.entries[index];
              return InboxRow(
                entry: entry,
                user: controller.userId,
                selected: controller.selectedKey == InboxController.key(entry),
                onOpen: () {
                  controller.select(entry);
                  onSelected?.call();
                },
              );
            },
          ),
        );
}
