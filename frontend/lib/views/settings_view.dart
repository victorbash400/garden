import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import '../components/settings/settings_transition.dart';
import '../components/connection_notice_button.dart';
import '../state/garden_controller.dart';
import 'account_settings.dart';
import 'connections_settings.dart';
import 'storage_settings.dart';
import 'activity_settings.dart';
import 'appearance_settings.dart';
import 'drives_settings.dart';
import 'notifications_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) {
    if (controller.settingsSection == SettingsSection.activity) {
      return ColoredBox(
        color: GardenColors.of(context).panel,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Activity',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 32),
                  Expanded(
                    child: ActivitySettings(
                      key: ValueKey(controller.account!.id),
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: ColoredBox(
        color: GardenColors.of(context).panel,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        switch (controller.settingsSection) {
                          SettingsSection.drives => 'Drives',
                          SettingsSection.notifications => 'Notifications',
                          SettingsSection.activity => 'Activity',
                          SettingsSection.appearance => 'Appearance',
                          SettingsSection.account => 'Account',
                          SettingsSection.storage => 'Storage',
                          SettingsSection.connections => 'Connections',
                        },
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),
                      if (controller.needsFinderAttention)
                        ConnectionNoticeButton(
                          onPressed: controller.openConnections,
                        ),
                    ],
                  ),
                  SizedBox(height: 32),
                  SettingsTransition(
                    child: KeyedSubtree(
                      key: ValueKey(controller.settingsSection),
                      child: switch (controller.settingsSection) {
                        SettingsSection.drives => DrivesSettings(
                          key: ValueKey(controller.account!.id),
                          controller: controller,
                        ),
                        SettingsSection.notifications => NotificationsSettings(
                          key: ValueKey(controller.account!.id),
                          controller: controller,
                        ),
                        SettingsSection.activity => SizedBox.shrink(),
                        SettingsSection.appearance =>
                          controller.appearance == null
                              ? Text('Appearance settings are unavailable.')
                              : AppearanceSettings(
                                  controller: controller.appearance!,
                                ),
                        SettingsSection.account => AccountSettings(
                          controller: controller,
                        ),
                        SettingsSection.storage => StorageSettings(
                          controller: controller,
                        ),
                        SettingsSection.connections => ConnectionsSettings(
                          controller: controller,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
