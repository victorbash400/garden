import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/garden_controller.dart';
import '../../ui/garden_theme.dart';
import 'settings_category.dart';

class SettingsSidebar extends StatelessWidget {
  const SettingsSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Container(
    width: 260,
    color: GardenTheme.sidebar,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: const Color(0xFFE1E5ED),
                child: Text(
                  controller.account!.email.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: GardenTheme.ink),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  controller.account!.email,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingsCategory(
          label: 'Account',
          icon: LucideIcons.userRound,
          selected: controller.settingsSection == SettingsSection.account,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.account),
        ),
        SettingsCategory(
          label: 'Storage',
          icon: LucideIcons.hardDrive,
          selected: controller.settingsSection == SettingsSection.storage,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.storage),
        ),
      ],
    ),
  );
}
