import 'package:flutter/material.dart';

import '../components/cache_limit_control.dart';
import '../components/settings/bandwidth_settings.dart';
import '../components/settings/cache_usage_controls.dart';
import '../components/settings/settings_group.dart';
import '../state/garden_controller.dart';

class StorageSettings extends StatefulWidget {
  const StorageSettings({super.key, required this.controller});
  final GardenController controller;

  @override
  State<StorageSettings> createState() => _StorageSettingsState();
}

class _StorageSettingsState extends State<StorageSettings> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.controller.storage?.watch();
        widget.controller.storage?.refresh();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.storage?.stopWatching();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final storage = controller.storage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            if (storage != null) CacheUsageControls(controller: storage),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CacheLimitControl(
                limit: storage?.usage?.limitGiB ?? controller.cacheLimit,
                busy: controller.busy || storage?.busy == true,
                onSave: controller.setCacheLimit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const BandwidthSettings(),
        const SizedBox(height: 12),
        const Text(
          'Caps Garden’s fetched file blocks. Other apps’ previews and copies are separate.',
          style: TextStyle(fontSize: 12, color: Color(0xFF77777A)),
        ),
      ],
    );
  }
}
