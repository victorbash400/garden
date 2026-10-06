import 'package:flutter/material.dart';

import '../../state/inbox_controller.dart';
import '../../ui/garden_colors.dart';
import '../chat/chat_drawer_button.dart';
import '../files/toolbar_button.dart';
import '../system_icon.dart';
import 'inbox_conversation_list.dart';

class InboxSidebar extends StatelessWidget {
  const InboxSidebar({
    super.key,
    required this.controller,
    required this.expanded,
    required this.onDrawer,
    required this.onNew,
  });
  final InboxController controller;
  final bool expanded;
  final VoidCallback onDrawer, onNew;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 240);
    return AnimatedContainer(
      duration: duration,
      curve: Curves.easeInOutCubic,
      width: expanded ? 280 : 50,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: colors.sidebar,
        border: Border(right: BorderSide(color: colors.sidebarBorder)),
      ),
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: 279,
        maxWidth: 279,
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    ChatDrawerButton(open: expanded, onPressed: onDrawer),
                    const Spacer(),
                    IgnorePointer(
                      ignoring: !expanded,
                      child: ExcludeSemantics(
                        excluding: !expanded,
                        child: AnimatedOpacity(
                          opacity: expanded ? 1 : 0,
                          duration: duration,
                          child: ToolbarButton(
                            tooltip: 'New conversation',
                            icon: SystemIcons.squarePen,
                            onPressed: onNew,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IgnorePointer(
                ignoring: !expanded,
                child: ExcludeSemantics(
                  excluding: !expanded,
                  child: AnimatedOpacity(
                    opacity: expanded ? 1 : 0,
                    duration: duration,
                    child: InboxConversationList(controller: controller),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
