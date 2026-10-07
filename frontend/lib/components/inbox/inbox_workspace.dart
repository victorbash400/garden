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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final sidebar = InboxSidebar(
            controller: controller,
            expanded: expanded,
            expandedWidth: narrow ? constraints.maxWidth : 280,
            onDrawer: onDrawer,
            onNew: onNew,
            onSelected: narrow && expanded ? onDrawer : null,
          );
          return Stack(
            children: [
              AnimatedPositioned(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                left: narrow || !expanded ? 50 : 280,
                top: 0,
                right: 0,
                bottom: 0,
                child: ExcludeFocus(
                  excluding: narrow && expanded,
                  child: ExcludeSemantics(
                    excluding: narrow && expanded,
                    child: IgnorePointer(
                      ignoring: narrow && expanded,
                      child: conversation,
                    ),
                  ),
                ),
              ),
              Positioned(left: 0, top: 0, bottom: 0, child: sidebar),
            ],
          );
        },
      ),
    );
  }
}
