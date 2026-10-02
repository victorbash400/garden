import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';
import 'garden_button.dart';

class SetupFinderStep extends StatelessWidget {
  const SetupFinderStep({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 460),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final drive in controller.gardens)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.hardDrive,
                  size: 20,
                  color: GardenTheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(drive.name, overflow: TextOverflow.ellipsis),
                ),
                if (controller.finderSyncing)
                  const Text(
                    'Connecting',
                    style: TextStyle(color: GardenTheme.secondary),
                  )
                else ...[
                  Text(
                    controller.finderEnabledDriveIDs.contains(drive.id)
                        ? 'Enabled'
                        : 'Not enabled',
                    style: const TextStyle(color: GardenTheme.secondary),
                  ),
                  const SizedBox(width: 12),
                  GardenButton(
                    label: 'Open in Finder',
                    secondary: true,
                    onPressed: controller.busy
                        ? null
                        : () => controller.openInFinder(drive),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 20),
        if (controller.finderEnabledDriveIDs.isEmpty &&
            !controller.finderSyncing) ...[
          const Text(
            'Enable Garden under System Settings → Login Items & Extensions → File Providers.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GardenTheme.secondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            if (controller.finderEnabledDriveIDs.isEmpty)
              GardenButton(
                label: 'Open System Settings',
                secondary: true,
                onPressed: controller.busy
                    ? null
                    : controller.openFinderSettings,
              ),
            GardenButton(
              label: 'Check Finder',
              secondary: true,
              onPressed: controller.busy || controller.finderSyncing
                  ? null
                  : controller.checkFinder,
            ),
          ],
        ),
      ],
    ),
  );
}
