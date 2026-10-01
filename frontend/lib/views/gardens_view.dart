import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../components/garden_button.dart';
import '../components/drive_dialog.dart';
import '../components/garden_row.dart';
import '../state/garden_controller.dart';

class GardensView extends StatelessWidget {
  const GardensView({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            GardenButton(
              label: 'Create drive',
              icon: LucideIcons.plus,
              onPressed: controller.busy
                  ? null
                  : () => showDriveDialog(context, controller),
            ),
            const SizedBox(width: 10),
            GardenButton(
              label: 'Join drive',
              secondary: true,
              onPressed: controller.busy
                  ? null
                  : () => showDriveDialog(context, controller, join: true),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Refresh drives',
              onPressed: controller.busy ? null : controller.refresh,
              icon: const Icon(LucideIcons.refreshCw, size: 17),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: controller.gardens.isEmpty
              ? const Center(child: Text('No drives connected.'))
              : ListView(
                  children: [
                    for (final garden in controller.gardens)
                      GardenRow(
                        garden: garden,
                        onConnect: controller.busy
                            ? null
                            : () => controller.connect(garden),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}
