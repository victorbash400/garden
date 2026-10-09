import 'package:flutter/material.dart';

import '../../model/garden_info.dart';
import '../../state/garden_controller.dart';
import '../../ui/garden_colors.dart';
import '../system_icon.dart';
import 'settings_inline_button.dart';

class DriveSettingsRow extends StatelessWidget {
  const DriveSettingsRow({
    super.key,
    required this.controller,
    required this.drive,
    required this.selected,
    required this.onSelect,
  });
  final GardenController controller;
  final GardenInfo drive;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    final status = controller.finderStatus;
    final mounted = status.enabled.contains(drive.id);
    final disabled = status.disabled.contains(drive.id);
    final pending = controller.changingMounts.contains(drive.id);
    return InkWell(
      onTap: onSelect,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SystemIcon(SystemIcons.hardDrive, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drive.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${drive.role} · ${pending
                        ? (mounted ? 'Unmounting…' : 'Mounting…')
                        : mounted
                        ? 'Mounted'
                        : disabled
                        ? 'Unmounted'
                        : 'Not connected'}',
                    style: TextStyle(fontSize: 12, color: colors.secondary),
                  ),
                ],
              ),
            ),
            if (pending)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (controller.canControlMounts)
              SettingsInlineButton(
                label: mounted ? 'Unmount' : 'Mount',
                onPressed: controller.finderSyncing
                    ? null
                    : () => controller.setDriveMounted(drive, !mounted),
              ),
            const SizedBox(width: 12),
            SystemIcon(
              selected ? SystemIcons.chevronDown : SystemIcons.chevronRight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
