import 'package:flutter/material.dart';

import '../../state/inbox_controller.dart';
import '../../ui/garden_colors.dart';
import 'inbox_sidebar.dart';

class InboxWorkspace extends StatelessWidget {
  const InboxWorkspace({
    super.key,
    required this.controller,
    required this.expanded,
    required this.onDrawer,
    required this.onNew,
    required this.conversation,
  });
  final InboxController controller;
  final bool expanded;
  final VoidCallback onDrawer, onNew;
  final Widget conversation;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.panel,
        borderRadius: BorderRadius.circular(14),
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          InboxSidebar(
            controller: controller,
            expanded: expanded,
            onDrawer: onDrawer,
            onNew: onNew,
          ),
          Expanded(child: conversation),
        ],
      ),
    );
  }
}
