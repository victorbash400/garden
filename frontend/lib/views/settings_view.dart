import 'package:flutter/material.dart';

import '../components/settings/settings_transition.dart';
import '../state/garden_controller.dart';
import 'account_settings.dart';
import 'storage_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    controller.settingsSection == SettingsSection.account
                        ? 'Account'
                        : 'Storage',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SettingsTransition(
                    child: KeyedSubtree(
                      key: ValueKey(controller.settingsSection),
                      child:
                          controller.settingsSection == SettingsSection.account
                          ? AccountSettings(controller: controller)
                          : StorageSettings(controller: controller),
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
