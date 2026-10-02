import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import 'drive_dialog.dart';
import 'garden_button.dart';

class SetupDriveStep extends StatelessWidget {
  const SetupDriveStep({super.key, required this.controller});

  final GardenController controller;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    alignment: WrapAlignment.center,
    children: [
      GardenButton(
        label: 'Create drive',
        onPressed: controller.busy
            ? null
            : () => showDriveDialog(context, controller),
      ),
      GardenButton(
        label: 'Join drive',
        secondary: true,
        onPressed: controller.busy
            ? null
            : () => showDriveDialog(context, controller, join: true),
      ),
    ],
  );
}
