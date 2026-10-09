import 'package:flutter/material.dart';

import '../../native/setup_links.dart';
import '../../state/garden_controller.dart';
import 'settings_inline_button.dart';
import 'settings_row.dart';

class MacFuseRow extends StatelessWidget {
  const MacFuseRow({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final installed = controller.nativeSetup?.status?.macFuseInstalled;
    return SettingsRow(
      label: 'macFUSE',
      value: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          Text(
            installed == null
                ? 'Not checked'
                : installed
                ? 'Installed'
                : 'Not installed',
          ),
          SettingsInlineButton(
            label: 'Get macFUSE',
            onPressed: controller.busy
                ? null
                : () => controller.openSetupHelp(SetupLink.macFuse),
          ),
        ],
      ),
    );
  }
}
