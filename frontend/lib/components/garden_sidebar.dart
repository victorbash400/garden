import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'garden_mark.dart';
import 'sidebar_item.dart';
import 'sidebar_drives.dart';

class GardenSidebar extends StatelessWidget {
  const GardenSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    color: const Color(0xFFF9F9F9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 54,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GardenMark(size: 18),
                SizedBox(width: 8),
                Text(
                  'Garden',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SidebarDrives(controller: controller),
          ),
        ),
        SidebarItem(
          icon: LucideIcons.settings,
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
