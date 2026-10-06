import 'package:flutter/material.dart';

import 'sidebar_surface.dart';

import '../state/garden_controller.dart';
import 'garden_mark.dart';
import 'sidebar_account_footer.dart';
import 'sidebar_drives.dart';

class GardenSidebar extends StatelessWidget {
  const GardenSidebar({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => SidebarSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
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
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SidebarDrives(controller: controller),
          ),
        ),
        SidebarAccountFooter(controller: controller),
      ],
    ),
  );
}
