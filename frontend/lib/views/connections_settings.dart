import 'package:flutter/material.dart';

import '../components/settings/finder_connection_row.dart';
import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';

class ConnectionsSettings extends StatelessWidget {
  const ConnectionsSettings({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SettingsGroup(
        children: [
          SettingsRow(
            label: 'Finder File Provider',
            value: Text(
              controller.finderSyncing
                  ? 'Connecting'
                  : '${controller.finderEnabledDriveIDs.length} of ${controller.finderConnectedDriveIDs.length} enabled',
            ),
          ),
          for (final drive in controller.gardens)
            FinderConnectionRow(drive: drive, controller: controller),
        ],
      ),
      if (controller.finderIssue != null) ...[
        const SizedBox(height: 14),
        Text(
          controller.finderIssue!,
          style: const TextStyle(color: Color(0xFFB23D3D), fontSize: 12),
        ),
      ],
      if (controller.needsFinderAttention) ...[
        const SizedBox(height: 12),
        const Text(
          'Enable Garden under System Settings → Login Items & Extensions → File Providers.',
          style: TextStyle(color: GardenTheme.secondary, fontSize: 12),
        ),
      ],
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        children: [
          TextButton(
            onPressed: controller.busy ? null : controller.openFinderSettings,
            child: const Text('Open System Settings'),
          ),
          TextButton(
            onPressed: controller.busy || controller.finderSyncing
                ? null
                : controller.checkFinder,
            child: const Text('Check again'),
          ),
          if (controller.finderIssue != null)
            TextButton(
              onPressed: controller.busy || controller.finderSyncing
                  ? null
                  : controller.refresh,
              child: const Text('Reconnect'),
            ),
        ],
      ),
    ],
  );
}
