import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/garden_controller.dart';
import 'settings_category.dart';

class SettingsSidebar extends StatelessWidget {
  const SettingsSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    decoration: const BoxDecoration(
      color: Color(0xFFF9F9F9),
      border: Border(right: BorderSide(color: Color(0xFFE8E8E8))),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 54,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
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
        SettingsCategory(
          label: 'Connections',
          icon: LucideIcons.plug,
          selected: controller.settingsSection == SettingsSection.connections,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.connections),
        ),
        const Spacer(),
        SettingsCategory(
          label: 'Back to drives',
          icon: LucideIcons.arrowLeft,
          selected: false,
          onTap: controller.busy ? null : controller.back,
        ),
        const SizedBox(height: 18),
      ],
    ),
  );
}
