import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../model/garden_info.dart';
import '../../state/garden_controller.dart';
import '../../ui/garden_theme.dart';

class FinderConnectionRow extends StatelessWidget {
  const FinderConnectionRow({
    super.key,
    required this.drive,
    required this.controller,
  });

  final GardenInfo drive;
  final GardenController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.finderConnectedDriveIDs.contains(drive.id);
    final enabled = controller.finderEnabledDriveIDs.contains(drive.id);
    final status = !selected
        ? 'Off'
        : controller.finderSyncing
        ? 'Connecting'
        : enabled
        ? 'Enabled'
        : 'Needs approval';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          const Icon(
            LucideIcons.hardDrive,
            size: 19,
            color: GardenTheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drive.name, style: const TextStyle(fontSize: 13)),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GardenTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            IconButton(
              tooltip: 'Open in Finder',
              onPressed: controller.busy
                  ? null
                  : () => controller.openInFinder(drive),
              icon: const Icon(LucideIcons.arrowUpRight, size: 16),
            ),
          Switch.adaptive(
            value: selected,
            onChanged: controller.busy || controller.finderSyncing
                ? null
                : (value) => controller.setFinderConnected(drive, value),
          ),
        ],
      ),
    );
  }
}
