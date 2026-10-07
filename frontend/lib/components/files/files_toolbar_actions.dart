import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../state/files_controller.dart';
import 'toolbar_group.dart';
import 'toolbar_button.dart';
import '../connection_notice_button.dart';
import 'file_view_selector.dart';

class FilesToolbarActions extends StatelessWidget {
  const FilesToolbarActions({
    super.key,
    required this.controller,
    required this.onImport,
    required this.onInvite,
    this.onConnections,
    this.onChat,
    this.onShare,
    this.chatUnread = 0,
    this.chatVisible = false,
  });
  final FilesController controller;
  final VoidCallback onImport;
  final VoidCallback? onInvite;
  final VoidCallback? onConnections, onChat, onShare;
  final int chatUnread;
  final bool chatVisible;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      FileViewSelector(controller: controller),
      ToolbarGroup(
        children: [
          onConnections != null
              ? ConnectionNoticeButton(onPressed: onConnections)
              : null,
          !controller.live
              ? ToolbarButton(
                  tooltip: 'Reconnect live updates',
                  onPressed: controller.busy ? null : controller.reconnect,
                  icon: SystemIcons.wifiOff,
                )
              : null,
          controller.path.isEmpty &&
                  onInvite != null &&
                  const {'Owner', 'Manager'}.contains(controller.drive!.role)
              ? ToolbarButton(
                  tooltip: 'Invite to drive',
                  onPressed: controller.busy ? null : onInvite,
                  icon: SystemIcons.userPlus,
                )
              : null,
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
          onShare != null
              ? ToolbarButton(
                  tooltip: 'Share',
                  onPressed: controller.selected == null || !controller.canWrite
                      ? null
                      : onShare,
                  icon: SystemIcons.external,
                )
              : null,
          onChat != null
              ? Badge(
                  isLabelVisible: chatUnread > 0,
                  label: Text('$chatUnread'),
                  child: ToolbarButton(
                    tooltip: 'Inbox',
                    selected: chatVisible,
                    onPressed: onChat,
                    icon: SystemIcons.inbox,
                  ),
                )
              : null,
        ],
      ),
    ],
  );
}
