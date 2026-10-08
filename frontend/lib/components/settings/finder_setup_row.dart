import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import '../../native/setup_links.dart';
import 'settings_row.dart';
import 'settings_inline_button.dart';

class FinderSetupRow extends StatelessWidget {
  const FinderSetupRow({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final available = controller.nativeSetup?.status?.finderAvailable;
    final status = controller.finderStatus;
    final missing = controller.nativeSetup?.status?.macFuseInstalled == false;
    final supported = controller.nativeSetup?.status?.finderSupported != false;
    final label = !supported
        ? 'Requires macOS 15.4 or later'
        : missing
        ? 'macFUSE not installed'
        : available == false
        ? 'Finder integration unavailable'
        : controller.finderSyncing
        ? 'Connecting'
        : controller.finderIssue != null
        ? 'Error'
        : status.disabled.isNotEmpty
        ? 'Permission required'
        : status.disconnected.isNotEmpty
        ? 'Disconnected'
        : controller.gardens.isEmpty
        ? available == true
              ? 'Approval not checked'
              : 'Not configured'
        : status.registered.length < controller.gardens.length
        ? 'Not connected'
        : 'Connected';
    return SettingsRow(
      label: 'Finder drives',
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          if (missing && supported) ...[
            const SizedBox(width: 12),
            SettingsInlineButton(
              label: 'Get macFUSE',
              onPressed: controller.busy
                  ? null
                  : () => controller.openSetupHelp(SetupLink.macFuse),
            ),
          ] else if (available != false && controller.finder != null) ...[
            const SizedBox(width: 12),
            SettingsInlineButton(
              onPressed: controller.busy || controller.finderSyncing
                  ? null
                  : status.disabled.isNotEmpty
                  ? controller.openFinderSettings
                  : controller.finderIssue != null ||
                        status.disconnected.isNotEmpty
                  ? controller.checkConnections
                  : () => controller.selectSettings(SettingsSection.drives),
              label: status.disabled.isNotEmpty
                  ? 'Enable…'
                  : controller.finderIssue != null ||
                        status.disconnected.isNotEmpty
                  ? 'Reconnect'
                  : 'Manage…',
            ),
          ],
        ],
      ),
    );
  }
}
