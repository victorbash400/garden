import 'package:flutter/material.dart';

import '../components/cache_limit_control.dart';
import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../state/garden_controller.dart';

class StorageSettings extends StatelessWidget {
  const StorageSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: CacheLimitControl(
          limit: controller.cacheLimit,
          busy: controller.busy,
          onSave: controller.setCacheLimit,
        ),
      ),
      SettingsRow(
        label: 'Finder connection',
        value: Text(controller.account == null
            ? 'Sign in to connect'
            : '${controller.mountedDriveCount} drives'),
      ),
    ],
  );
}
