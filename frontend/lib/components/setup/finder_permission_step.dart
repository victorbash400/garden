import 'package:flutter/material.dart';

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
        'Finder drives require macOS 15.4 or later and macFUSE. '
        'Install macFUSE, then approve it '
        'in System Settings → General → Login Items & Extensions → '
        'File System Extensions. Allow Garden background activity there too.',
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
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
