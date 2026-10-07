import '../system_icon.dart';

import 'package:flutter/material.dart';

import 'toolbar_entrance.dart';

import 'home_breadcrumb.dart';

import '../../state/files_controller.dart';
import 'toolbar_button.dart';
import 'toolbar_group.dart';
import 'files_toolbar_actions.dart';

class FilesToolbar extends StatelessWidget {
  const FilesToolbar({
    super.key,
    required this.controller,
    required this.onImport,
    required this.onInvite,
    required this.onBackToDrives,
    this.onConnections,
    this.onChat,
    this.onShare,
    this.chatUnread = 0,
    this.chatVisible = false,
  });
  final FilesController controller;
  final VoidCallback onImport;
  final VoidCallback? onInvite;
  final VoidCallback onBackToDrives;
  final VoidCallback? onConnections, onChat, onShare;
  final int chatUnread;
  final bool chatVisible;
  @override
  Widget build(BuildContext context) => ToolbarEntrance(
    child: LayoutBuilder(
      builder: (context, constraints) {
        final actions = FilesToolbarActions(
          controller: controller,
          onImport: onImport,
          onInvite: onInvite,
          onConnections: onConnections,
          onChat: onChat,
          onShare: onShare,
          chatUnread: chatUnread,
          chatVisible: chatVisible,
        );
        final navigation = Row(
          children: [
            ToolbarGroup(
              children: [
                ToolbarButton(
                  tooltip: controller.path.isEmpty
                      ? 'Back to drives'
                      : 'Parent folder',
                  onPressed: controller.busy
                      ? null
                      : controller.path.isEmpty
                      ? onBackToDrives
                      : () => controller.goTo(controller.path.length - 1),
                  icon: SystemIcons.arrowLeft,
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: HomeBreadcrumb(
                controller: controller,
                onHome: onBackToDrives,
              ),
            ),
          ],
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: constraints.maxWidth < 620
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 44, child: navigation),
                    Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(child: navigation),
                      actions,
                    ],
                  ),
                ),
        );
      },
    ),
  );
}
