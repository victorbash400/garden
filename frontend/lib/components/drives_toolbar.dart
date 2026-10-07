import 'system_icon.dart';

import 'package:flutter/material.dart';

import 'files/toolbar_entrance.dart';

import '../state/garden_controller.dart';
import 'garden_button.dart';
import 'drive_dialog.dart';
import 'connection_notice_button.dart';

class DrivesToolbar extends StatelessWidget {
  const DrivesToolbar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => ToolbarEntrance(
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: GardenButton(
                  label: 'Create drive',
                  icon: SystemIcons.plus,
                  onPressed: controller.busy
                      ? null
                      : () => showDriveDialog(context, controller),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: GardenButton(
                  label: 'Invitations',
                  secondary: true,
                  onPressed: controller.busy
                      ? null
                      : () {
                          controller.selectSettings(
                            SettingsSection.notifications,
                          );
                          controller.navigate(GardenPage.settings);
                        },
                ),
              ),
            ],
          ),
        ),
        if (controller.needsFinderAttention)
          ConnectionNoticeButton(onPressed: controller.openConnections),
        IconButton(
          tooltip: 'Refresh drives',
          onPressed: controller.busy ? null : controller.refresh,
          icon: const SystemIcon(SystemIcons.refreshCw, size: 17),
        ),
      ],
    ),
  );
}
