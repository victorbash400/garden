import 'package:flutter/material.dart';

import '../../native/setup_links.dart';
import '../../state/garden_controller.dart';
import '../settings/settings_group.dart';
import '../settings/settings_inline_button.dart';
import '../settings/settings_row.dart';

class InstallationStep extends StatelessWidget {
  const InstallationStep({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Move Garden to Applications before setting up Finder drives.',
      ),
      const SizedBox(height: 20),
      SettingsGroup(
        children: [
          SettingsRow(
            label: 'Manual approval',
            value: SettingsInlineButton(
              label: 'Apple instructions',
              onPressed: controller.busy
                  ? null
                  : () => controller.openSetupHelp(SetupLink.approval),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'If macOS blocks the downloaded app, open System Settings → '
              'Privacy & Security and choose Open Anyway for Garden. '
              'Approve only the build you downloaded from the Garden release.',
            ),
          ),
        ],
      ),
    ],
  );
}
