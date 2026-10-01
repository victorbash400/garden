import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'drive_folder_branch.dart';
import 'tree_row.dart';
import 'drive_section_header.dart';
import 'drive_dialog.dart';

class SidebarDrives extends StatefulWidget {
  const SidebarDrives({super.key, required this.controller});
  final GardenController controller;
  @override
  State<SidebarDrives> createState() => _SidebarDrivesState();
}

class _SidebarDrivesState extends State<SidebarDrives> {
  final collapsed = <int>{};
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final files = controller.files;
    Widget content() => ListView(
      children: [
        DriveSectionHeader(
          label: 'Drives',
          actionLabel: 'Create drive',
          onAdd: controller.busy
              ? null
              : () => showDriveDialog(context, controller),
          onOpen: controller.busy
              ? null
              : () => controller.navigate(GardenPage.gardens),
        ),
        for (final drive in controller.gardens) ...[
          TreeRow(
            label: drive.name,
            icon: LucideIcons.folder,
            connected: drive.role != 'Owner',
            depth: 0,
            selected:
                controller.page == GardenPage.files &&
                files?.drive?.id == drive.id &&
                files!.path.isEmpty,
            expanded:
                files?.drive?.id == drive.id && !collapsed.contains(drive.id),
            onOpen: controller.busy ? null : () => controller.openDrive(drive),
            onToggle:
                controller.busy ||
                    files?.drive?.id != drive.id ||
                    !files!.folders.hasChildren(0)
                ? null
                : () => setState(() {
                    if (!collapsed.add(drive.id)) {
                      collapsed.remove(drive.id);
                    }
                  }),
          ),
          if (files != null &&
              files.drive?.id == drive.id &&
              !collapsed.contains(drive.id))
            DriveFolderBranch(
              key: ValueKey(drive.id),
              controller: files,
              parentId: 0,
              depth: 1,
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
