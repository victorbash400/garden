import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../state/garden_controller.dart';
import '../components/settings/finder_setup_row.dart';
import '../components/settings/login_item_row.dart';
import '../components/settings/background_updates_row.dart';

class ConnectionsSettings extends StatelessWidget {
  const ConnectionsSettings({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) {
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
            FinderSetupRow(controller: controller),
            if (controller.finderUpdates != null)
              BackgroundUpdatesRow(updates: controller.finderUpdates!),
            if (controller.nativeSetup != null)
              LoginItemRow(controller: controller.nativeSetup!),
          ],
        ),
        for (final issue in [
          controller.finderIssue,
          controller.finderUpdates?.error,
          controller.nativeSetup?.error,
        ].whereType<String>().toSet()) ...[
          const SizedBox(height: 12),
          SelectableText(
            issue,
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
