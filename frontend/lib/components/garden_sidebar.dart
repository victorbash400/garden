import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import '../ui/garden_theme.dart';
import 'garden_mark.dart';
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GardenMark(size: 19),
              SizedBox(width: 9),
              Text(
                'Garden',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SidebarItem(
          icon: LucideIcons.folder,
          label: 'Drives',
          selected: controller.page == GardenPage.gardens,
          onTap: controller.busy
              ? null
              : () => controller.navigate(
                  controller.account == null
                      ? GardenPage.welcome
                      : GardenPage.gardens,
                ),
        ),
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
