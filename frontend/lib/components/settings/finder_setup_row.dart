import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import 'settings_row.dart';
import 'settings_inline_button.dart';

class FinderSetupRow extends StatelessWidget {
  const FinderSetupRow({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final available = controller.nativeSetup?.status?.finderAvailable;
    final status = controller.finderStatus;
    final label = available == false
        ? 'Extension missing'
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
      label: 'Finder File Provider',
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          if (available != false && controller.finder != null) ...[
            const SizedBox(width: 12),
            SettingsInlineButton(
              onPressed: controller.busy ? null : controller.openFinderSettings,
              label: status.disabled.isNotEmpty ? 'Enable…' : 'Manage…',
            ),
          ],
        ],
      ),
    );
  }
}
