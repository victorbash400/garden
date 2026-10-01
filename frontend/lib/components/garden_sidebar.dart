import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';
import 'sidebar_account.dart';
import 'sidebar_item.dart';
import 'sidebar_drives.dart';

class GardenSidebar extends StatelessWidget {
  const GardenSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    color: GardenTheme.sidebar,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        SidebarAccount(controller: controller),
        const SizedBox(height: 16),
        const SizedBox(height: 8),
        Expanded(child: SidebarDrives(controller: controller)),
        SidebarItem(
          icon: LucideIcons.settings2,
          label: 'Settings',
          selected: controller.page == GardenPage.settings,
          onTap: controller.busy
              ? null
              : () => controller.navigate(GardenPage.settings),
        ),
        const SizedBox(height: 18),
      ],
    ),
  );
}
