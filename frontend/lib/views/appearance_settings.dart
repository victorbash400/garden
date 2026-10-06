import 'package:flutter/material.dart';

import '../state/appearance_controller.dart';
import '../model/appearance/theme_presets.dart';
import '../model/appearance/theme_profile.dart';
import '../components/appearance/theme_profile_controls.dart';
import '../components/appearance/theme_mode_control.dart';
import '../components/appearance/appearance_advanced.dart';
import '../components/settings/settings_row.dart';
import '../components/settings/settings_group.dart';
import '../components/error_notice.dart';

class AppearanceSettings extends StatelessWidget {
  const AppearanceSettings({super.key, required this.controller});
  final AppearanceController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      final profile = dark ? controller.dark : controller.light;
      Future<void> update(ThemeProfile profile) => dark
          ? controller.update(dark: profile)
          : controller.update(light: profile);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.error != null) ...[
            ErrorNotice(
              message: controller.error!,
              action: 'Retry',
              onAction: controller.load,
            ),
            const SizedBox(height: 20),
          ],
          SettingsGroup(
            children: [
              SettingsRow(
                label: 'Mode',
                value: ThemeModeControl(
                  mode: controller.mode,
                  light: controller.light,
                  dark: controller.dark,
                  onChanged: controller.busy
                      ? null
                      : (mode) => controller.update(mode: mode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ThemeProfileControls(
            key: ValueKey(dark),
            profile: profile,
            presets: dark ? darkPresets : lightPresets,
            onChanged: controller.busy ? null : update,
          ),
          const SizedBox(height: 20),
          AppearanceAdvanced(
            contrast: profile.contrast,
            onChanged: controller.busy
                ? null
                : (contrast) => update(profile.copyWith(contrast: contrast)),
            onReset: controller.busy
                ? null
                : () => update((dark ? darkPresets : lightPresets).first),
          ),
        ],
      );
    },
  );
}
