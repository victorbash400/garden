import '../system_icon.dart';

import 'package:flutter/material.dart';

import 'home_breadcrumb.dart';

import '../../state/files_controller.dart';
import 'toolbar_button.dart';
import 'toolbar_group.dart';
import '../connection_notice_button.dart';
import 'file_view_selector.dart';

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
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Row(
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
          FileViewSelector(controller: controller),
          SizedBox(width: 8),
          ToolbarGroup(
            children: [
              if (onConnections != null)
                ConnectionNoticeButton(onPressed: onConnections),
              if (!controller.live)
                ToolbarButton(
                  tooltip: 'Reconnect live updates',
                  onPressed: controller.busy ? null : controller.reconnect,
                  icon: SystemIcons.wifiOff,
                ),
              if (controller.path.isEmpty &&
                  onInvite != null &&
                  const {'Owner', 'Manager'}.contains(controller.drive!.role))
                ToolbarButton(
                  tooltip: 'Invite to drive',
                  onPressed: controller.busy ? null : onInvite,
                  icon: SystemIcons.userPlus,
                ),
              ListenableBuilder(
                listenable: controller.imports,
                builder: (_, _) => ToolbarButton(
                  tooltip: 'Import files',
                  onPressed: controller.imports.busy || !controller.canWrite
                      ? null
                      : onImport,
                  icon: SystemIcons.importFiles,
                ),
              ),
              if (onShare != null)
                ToolbarButton(
                  tooltip: 'Share',
                  onPressed: controller.selected == null || !controller.canWrite
                      ? null
                      : onShare,
                  icon: SystemIcons.external,
                ),
              if (onChat != null)
                Badge(
                  isLabelVisible: chatUnread > 0,
                  label: Text('$chatUnread'),
                  child: ToolbarButton(
                    tooltip: 'Inbox',
                    selected: chatVisible,
                    onPressed: onChat,
                    icon: SystemIcons.inbox,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}
