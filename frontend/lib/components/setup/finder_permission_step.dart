import 'package:flutter/material.dart';

import '../../native/setup_links.dart';
import '../../state/garden_controller.dart';
import '../../views/connections_settings.dart';
import '../settings/settings_inline_button.dart';

class FinderPermissionStep extends StatelessWidget {
  const FinderPermissionStep({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Finder drives require macFUSE. Install it, then approve macFUSE '
        'in System Settings → General → Login Items & Extensions → '
        'File System Extensions. Allow Garden background activity there too.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          SettingsInlineButton(
            label: 'Get macFUSE',
            onPressed: controller.busy
                ? null
                : () => controller.openSetupHelp(SetupLink.macFuse),
          ),
          if (controller.nativeSetup != null)
            SettingsInlineButton(
              label: 'Open System Settings',
              onPressed: controller.busy
                  ? null
                  : controller.nativeSetup!.openLoginSettings,
            ),
        ],
      ),
      const SizedBox(height: 20),
      ConnectionsSettings(controller: controller),
    ],
  );
}
