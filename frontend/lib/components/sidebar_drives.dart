import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'drive_folder_branch.dart';
import 'tree_row.dart';

class SidebarDrives extends StatefulWidget {
  const SidebarDrives({super.key, required this.controller});
  final GardenController controller;
  @override
  State<SidebarDrives> createState() => _SidebarDrivesState();
}

class _SidebarDrivesState extends State<SidebarDrives> {
  final collapsed = <int>{};
  final collapsedGroups = <String>{};
  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final files = controller.files;
    Widget content() => ListView(
      children: [
        for (final owned in [true, false]) ...[
          TreeRow(
            label: owned ? 'Owned drives' : 'Connected drives',
            icon: owned ? LucideIcons.hardDrive : LucideIcons.users,
            selected: controller.page == GardenPage.gardens,
            expanded: !collapsedGroups.contains(owned.toString()),
            onToggle: () => setState(() {
              final key = owned.toString();
              if (!collapsedGroups.add(key)) collapsedGroups.remove(key);
            }),
            onOpen: controller.busy
                ? null
                : () => controller.navigate(GardenPage.gardens),
          ),
          if (!collapsedGroups.contains(owned.toString()))
            for (final drive in controller.gardens.where(
              (drive) => (drive.role == 'Owner') == owned,
            )) ...[
              TreeRow(
                label: drive.name,
                icon: LucideIcons.hardDrive,
                depth: 1,
                selected:
                    controller.page == GardenPage.files &&
                    files?.drive?.id == drive.id &&
                    files!.path.isEmpty,
                expanded:
                    files?.drive?.id == drive.id &&
                    !collapsed.contains(drive.id),
                onOpen: controller.busy
                    ? null
                    : () => controller.openDrive(drive),
                onToggle: controller.busy
                    ? null
                    : () async {
                        if (files?.drive?.id != drive.id) {
                          await controller.openDrive(drive);
                          if (mounted) {
                            setState(() => collapsed.remove(drive.id));
                          }
                        } else {
                          setState(() {
                            if (!collapsed.add(drive.id)) {
                              collapsed.remove(drive.id);
                            }
                          });
                        }
                      },
              ),
              if (files != null &&
                  files.drive?.id == drive.id &&
                  !collapsed.contains(drive.id))
                DriveFolderBranch(
                  key: ValueKey(drive.id),
                  controller: files,
                  parentId: 0,
                  depth: 2,
                  onNavigate: () => controller.navigate(GardenPage.files),
                ),
            ],
        ],
      ],
    );
    return files == null
        ? content()
        : ListenableBuilder(listenable: files, builder: (_, _) => content());
  }
}
