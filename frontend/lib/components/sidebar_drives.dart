import 'system_icon.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../state/garden_controller.dart';
import 'drive_folder_branch.dart';
import 'tree_row.dart';
import 'sidebar_item.dart';
import 'drive_section_header.dart';
import 'drive_row_actions.dart';
import 'files/node_drag_surface.dart';

class SidebarDrives extends StatefulWidget {
  const SidebarDrives({super.key, required this.controller});
  final GardenController controller;
  @override
  State<SidebarDrives> createState() => _SidebarDrivesState();
}

class _SidebarDrivesState extends State<SidebarDrives> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final files = controller.files;
    Widget content() => ListView(
      children: [
        SidebarItem(
          label: 'Home',
          icon: SystemIcons.house,
          selected: controller.page == GardenPage.gardens,
          onTap: () => controller.navigate(GardenPage.gardens),
        ),
        DriveSectionHeader(
          label: 'Drives',
          onOpen: controller.busy
              ? null
              : () => controller.navigate(GardenPage.gardens),
        ),
        if (files != null)
          for (final drive in controller.gardens) ...[
            NodeDragSurface(
              controller: files,
              driveId: drive.id,
              parentId: 0,
              child: TreeRow(
                label: drive.name,
                actions: DriveRowActions(drive: drive, controller: controller),
                icon: SystemIcons.hardDrive,
                connected: drive.role != 'Owner',
                depth: 0,
                selected:
                    controller.page == GardenPage.files &&
                    files.drive?.id == drive.id &&
                    files.path.isEmpty,
                expanded: files.folderIndex(drive.id).expandedRoot,
                onOpen: controller.busy
                    ? null
                    : () => controller.openDrive(drive, root: true),
                onToggle:
                    controller.busy ||
                        (files.folderIndex(drive.id).isLoaded(0) &&
                            !files.folderIndex(drive.id).hasChildren(0))
                    ? null
                    : () async {
                        final index = files.folderIndex(drive.id);
                        if (!index.expandedRoot) {
                          await files.loadDriveChildren(drive.id, 0);
                        }
                        if (mounted && index.isLoaded(0)) {
                          setState(
                            () => index.expandedRoot = !index.expandedRoot,
                          );
                        }
                      },
              ),
            ),
            if (files.folderIndex(drive.id).expandedRoot)
              DriveFolderBranch(
                key: ValueKey(drive.id),
                controller: files,
                drive: drive,
                parentId: 0,
                depth: 1,
                onNavigate: (node) async {
                  await controller.openDrive(drive);
                  if (files.drive?.id != drive.id || files.error != null) {
                    return;
                  }
                  if (node.kind == NodeKind.folder) {
                    await files.openFolder(node);
                  } else {
                    final path = files.folders.pathTo(node);
                    if (path.length == 1) {
                      await files.goTo(0);
                    } else {
                      await files.openFolder(path[path.length - 2]);
                    }
                    files.select(node);
                  }
                },
              ),
          ],
      ],
    );
    return files == null
        ? content()
        : ListenableBuilder(listenable: files, builder: (_, _) => content());
  }
}
