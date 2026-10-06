import 'package:flutter/material.dart';

import '../../state/storage_controller.dart';
import 'settings_inline_button.dart';

class CacheUsageActions extends StatelessWidget {
  const CacheUsageActions({super.key, required this.controller});
  final StorageController controller;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      SettingsInlineButton(
        label: 'Refresh',
        onPressed: controller.busy ? null : controller.refresh,
      ),
      SettingsInlineButton(
        label: 'Clear cache',
        onPressed:
            controller.busy ||
                controller.usage?.available != true ||
                controller.usage?.usedBytes == 0
            ? null
            : controller.clear,
      ),
    ],
  );
}
