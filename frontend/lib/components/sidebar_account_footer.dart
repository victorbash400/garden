import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import 'build_update_banner.dart';
import 'profile_button.dart';

class SidebarAccountFooter extends StatelessWidget {
  const SidebarAccountFooter({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (controller.accountWindow != null)
        BuildUpdateBanner(window: controller.accountWindow!),
      ProfileButton(controller: controller),
      const SizedBox(height: 18),
    ],
  );
}
