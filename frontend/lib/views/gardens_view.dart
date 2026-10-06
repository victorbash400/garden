import 'package:flutter/material.dart';

import '../components/garden_row.dart';
import '../components/drives_toolbar.dart';
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
        DrivesToolbar(controller: controller),
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
                            : () => controller.openDrive(garden),
                      ),
                  ],
                ),
        ),
      ],
    ),
  );
}
