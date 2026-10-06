import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../sidebar_surface.dart';

import '../../state/garden_controller.dart';
import 'settings_category.dart';
import '../activity_icon.dart';
import '../sidebar_account_footer.dart';

class SettingsSidebar extends StatelessWidget {
  const SettingsSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => SidebarSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
          icon: SystemIcon(SystemIcons.userRound),
          selected: controller.settingsSection == SettingsSection.account,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.account),
        ),
        SettingsCategory(
          label: 'Storage',
          icon: SystemIcon(SystemIcons.hardDrive),
          selected: controller.settingsSection == SettingsSection.storage,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.storage),
        ),
        SettingsCategory(
          label: 'Connections',
          icon: SystemIcon(SystemIcons.plug),
          selected: controller.settingsSection == SettingsSection.connections,
          onTap: controller.busy
              ? null
              : () => controller.selectSettings(SettingsSection.connections),
        ),
        SettingsCategory(
          label: 'Drives',
          icon: const SystemIcon(SystemIcons.hardDrive),
          selected: controller.settingsSection == SettingsSection.drives,
          onTap: () => controller.selectSettings(SettingsSection.drives),
        ),
        SettingsCategory(
          label: 'Notifications',
          icon: const SystemIcon(SystemIcons.bell),
          selected: controller.settingsSection == SettingsSection.notifications,
          onTap: () => controller.selectSettings(SettingsSection.notifications),
        ),
        SettingsCategory(
          label: 'Appearance',
          icon: SystemIcon(SystemIcons.palette),
          selected: controller.settingsSection == SettingsSection.appearance,
          onTap: () => controller.selectSettings(SettingsSection.appearance),
        ),
        SettingsCategory(
          label: 'Activity',
          icon: ActivityIcon(),
          selected: controller.settingsSection == SettingsSection.activity,
          onTap: () => controller.selectSettings(SettingsSection.activity),
        ),
        Spacer(),
        SettingsCategory(
          label: 'Back to drives',
          icon: SystemIcon(SystemIcons.arrowLeft),
          selected: false,
          onTap: controller.busy ? null : controller.back,
        ),
        SizedBox(height: 8),
        SidebarAccountFooter(controller: controller),
      ],
    ),
  );
}
