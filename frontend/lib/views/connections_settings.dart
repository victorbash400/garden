import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../state/garden_controller.dart';

class ConnectionsSettings extends StatelessWidget {
  const ConnectionsSettings({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final hasDrives = controller.gardens.isNotEmpty;
    final finderReady =
        hasDrives &&
        controller.finderEnabledDriveIDs.length == controller.gardens.length;
    final finderStatus = controller.finderSyncing
        ? 'Connecting'
        : controller.finderIssue != null
        ? 'Error'
        : !hasDrives
        ? 'Ready for drives'
        : controller.finderPermissionRequired
        ? 'Permission required'
        : finderReady
        ? 'Connected'
        : 'Needs attention';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              label: 'Garden service',
              value: Text(
                controller.serviceAvailable
                    ? 'Available at last check'
                    : 'Unavailable',
              ),
            ),
            SettingsRow(
              label: 'Finder File Provider',
              value: Text(finderStatus),
            ),
          ],
        ),
        if (controller.finderPermissionRequired) ...[
          const SizedBox(height: 12),
          const Text(
            'Enable Garden in System Settings → Login Items & Extensions → File Providers.',
            style: TextStyle(fontSize: 12, color: Color(0xFF686868)),
          ),
          TextButton(
            onPressed: controller.busy ? null : controller.openFinderSettings,
            child: const Text('Open System Settings'),
          ),
        ],
        if (controller.finderIssue != null) ...[
          const SizedBox(height: 12),
          Text(
            controller.finderIssue!,
            style: const TextStyle(fontSize: 12, color: Color(0xFFB23D3D)),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: controller.busy || controller.finderSyncing
              ? null
              : controller.checkConnections,
          child: const Text('Check connections'),
        ),
      ],
    );
  }
}
