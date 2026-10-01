import 'package:flutter/material.dart';

import '../components/settings/settings_toolbar.dart';
import '../components/settings/settings_transition.dart';
import '../state/garden_controller.dart';
import 'account_settings.dart';
import 'storage_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.white,
    child: Padding(
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
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 32),
                    child: SettingsTransition(
                      child: KeyedSubtree(
                        key: ValueKey(controller.settingsSection),
                        child:
                            controller.settingsSection ==
                                SettingsSection.account
                            ? AccountSettings(controller: controller)
                            : StorageSettings(controller: controller),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
