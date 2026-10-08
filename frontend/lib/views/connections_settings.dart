import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../state/garden_controller.dart';
import '../components/settings/finder_setup_row.dart';
import '../components/settings/mac_fuse_row.dart';
import '../components/settings/login_item_row.dart';
import '../components/settings/background_updates_row.dart';
import '../components/settings/settings_inline_button.dart';
import '../components/settings/connection_issue_row.dart';

class ConnectionsSettings extends StatelessWidget {
  const ConnectionsSettings({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final issues = [
      controller.finderIssue,
      controller.finderUpdates?.error,
      controller.nativeSetup?.error,
    ].whereType<String>().toSet();
    return SettingsGroup(
      children: [
        SettingsRow(
          label: 'Garden service',
          value: Text(
            controller.serviceAvailable ? 'Available' : 'Unavailable',
          ),
        ),
        MacFuseRow(controller: controller),
        FinderSetupRow(controller: controller),
        if (controller.finderUpdates != null)
          BackgroundUpdatesRow(updates: controller.finderUpdates!),
        if (controller.nativeSetup != null)
          LoginItemRow(controller: controller.nativeSetup!),
        if (issues.isNotEmpty) ConnectionIssueRow(details: issues.join('\n')),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerRight,
            child: SettingsInlineButton(
              onPressed: controller.busy || controller.finderSyncing
                  ? null
                  : controller.checkConnections,
              label: 'Check connections',
            ),
          ),
        ),
      ],
    );
  }
}
