import 'package:flutter/material.dart';

import '../components/settings/settings_toolbar.dart';
import '../state/garden_controller.dart';
import 'account_settings.dart';
import 'storage_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      children: [
        SettingsToolbar(
          label: controller.settingsSection == SettingsSection.account
              ? 'Account'
              : 'Storage',
          onBack: controller.busy ? null : controller.back,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 660),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: controller.settingsSection == SettingsSection.account
                      ? AccountSettings(controller: controller)
                      : StorageSettings(controller: controller),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
