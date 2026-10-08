import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import 'build_update_banner.dart';
import 'profile_button.dart';
import 'sharing/notification_bell.dart';

class SidebarAccountFooter extends StatelessWidget {
  const SidebarAccountFooter({super.key, required this.controller});
  final GardenController controller;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (controller.accountWindow != null)
        BuildUpdateBanner(window: controller.accountWindow!),
      Row(
        children: [
          ProfileButton(controller: controller),
          const Spacer(),
          if (controller.account != null && controller.notifications != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: NotificationBell(controller: controller),
            ),
        ],
      ),
      const SizedBox(height: 18),
    ],
  );
}
