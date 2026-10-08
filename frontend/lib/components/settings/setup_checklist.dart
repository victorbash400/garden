import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import 'login_item_row.dart';
import 'settings_group.dart';
import 'setup_step_row.dart';

class SetupChecklist extends StatelessWidget {
  const SetupChecklist({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final drives = controller.gardens;
    final finder = controller.finderStatus;
    final connected =
        drives.isNotEmpty &&
        controller.finderIssue == null &&
        !controller.finderSyncing &&
        drives.every(
          (drive) =>
              finder.enabled.contains(drive.id) &&
              !finder.disconnected.contains(drive.id),
        );
    final enabled = !controller.busy && !controller.finderSyncing;
    return SettingsGroup(
      children: [
        SetupStepRow(
          number: 1,
          label: 'Create account',
          complete: controller.account != null,
          action: '',
          onPressed: null,
        ),
        SetupStepRow(
          number: 2,
          label: 'Connect to Garden',
          complete: controller.serviceAvailable,
          action: 'Check connection',
          onPressed: enabled ? controller.checkConnections : null,
        ),
        SetupStepRow(
          number: 3,
          label: 'Create or join a drive',
          complete: drives.isNotEmpty,
          action: drives.isEmpty ? 'Create drive' : 'Manage drives',
          onPressed: enabled
              ? () {
                  if (drives.isEmpty) {
                    controller.navigate(GardenPage.create);
                  } else {
                    controller.selectSettings(SettingsSection.drives);
                  }
                }
              : null,
        ),
        SetupStepRow(
          number: 4,
          label: 'Connect drives in Finder',
          complete: connected,
          action: connected ? 'Open in Finder' : 'Set up Finder',
          onPressed: enabled
              ? () {
                  if (connected) {
                    controller.openInFinder(drives.first);
                  } else {
                    controller.openConnections();
                  }
                }
              : null,
        ),
        if (controller.nativeSetup != null)
          LoginItemRow(controller: controller.nativeSetup!),
      ],
    );
  }
}
