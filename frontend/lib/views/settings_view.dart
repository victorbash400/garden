import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import '../components/garden_button.dart';
import '../components/cache_limit_control.dart';
import '../ui/garden_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (controller.account != null) ...[
            Text(controller.account!.email),
            const SizedBox(height: 16),
            GardenButton(
              label: 'Sign out',
              secondary: true,
              onPressed: controller.busy ? null : controller.signOut,
            ),
            const SizedBox(height: 36),
          ],
          CacheLimitControl(
            limit: controller.cacheLimit,
            busy: controller.busy,
            onSave: controller.setCacheLimit,
          ),
          const Text(
            'Saved for the future Finder connection.',
            style: TextStyle(fontSize: 12, color: GardenTheme.secondary),
          ),
        ],
      ),
    ),
  );
}
