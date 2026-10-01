import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'drive_folder_branch.dart';
import 'sidebar_item.dart';

class SidebarDrives extends StatelessWidget {
  const SidebarDrives({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) {
    final files = controller.files;
    Widget content() => ListView(
      children: [
        for (final drive in controller.gardens) ...[
          SidebarItem(
            icon: LucideIcons.hardDrive,
            label: drive.name,
            selected:
                controller.page == GardenPage.files &&
                files?.drive?.id == drive.id &&
                files!.path.isEmpty,
            onTap: controller.busy ? null : () => controller.openDrive(drive),
          ),
          if (files != null && files.drive?.id == drive.id)
            DriveFolderBranch(
              controller: files,
              parentId: 0,
              onNavigate: () => controller.navigate(GardenPage.files),
            ),
        ],
      ],
    );
    return files == null
        ? content()
        : ListenableBuilder(listenable: files, builder: (_, _) => content());
  }
}
