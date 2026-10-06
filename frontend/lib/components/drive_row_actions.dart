import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import '../model/garden_info.dart';
import '../state/garden_controller.dart';
import 'files/file_actions.dart';
import 'files/node_name_dialog.dart';

class DriveRowActions extends StatelessWidget {
  const DriveRowActions({
    super.key,
    required this.drive,
    required this.controller,
  });
  final GardenInfo drive;
  final GardenController controller;
  Future<void> createFolder(BuildContext context) async {
    await controller.openDrive(drive, root: true);
    final files = controller.files;
    if (context.mounted && controller.error == null && files != null) {
      await FileActions(context, files).create('folder');
    }
  }

  Future<void> rename(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => NodeNameDialog(action: 'Rename', value: drive.name),
    );
    if (name != null) await controller.renameDrive(drive, name);
  }

  Future<void> delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${drive.name}?'),
        content: Text(
          'This removes the drive for everyone. Its files are retained in storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete drive',
              style: TextStyle(color: GardenColors.of(context).danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteDrive(drive);
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (drive.canWrite)
        SizedBox(
          width: 24,
          height: 28,
          child: IconButton(
            tooltip: 'New folder in ${drive.name}',
            padding: EdgeInsets.zero,
            onPressed: controller.busy ? null : () => createFolder(context),
            icon: SystemIcon(
              SystemIcons.plus,
              size: 14,
              color: GardenColors.of(context).ink,
            ),
          ),
        ),
      if (drive.canWrite)
        SizedBox(
          width: 24,
          height: 28,
          child: PopupMenuButton<String>(
            tooltip: 'Actions for ${drive.name}',
            enabled: !controller.busy,
            padding: EdgeInsets.zero,
            icon: SystemIcon(
              SystemIcons.ellipsis,
              size: 15,
              color: GardenColors.of(context).ink,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: GardenColors.of(context).border),
            ),
            color: GardenColors.of(context).panel,
            elevation: 1,
            onSelected: (value) async {
              if (value == 'rename') await rename(context);
              if (value == 'folder' && context.mounted) {
                await createFolder(context);
              }
              if (value == 'delete' && context.mounted) await delete(context);
            },
            itemBuilder: (_) => [
              if (drive.role == 'Owner')
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      SystemIcon(SystemIcons.squarePen, size: 16),
                      SizedBox(width: 10),
                      Text('Rename…'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'folder',
                child: Row(
                  children: [
                    SystemIcon(SystemIcons.folderPlus, size: 16),
                    SizedBox(width: 10),
                    Text('New folder'),
                  ],
                ),
              ),
              if (drive.role == 'Owner')
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      SystemIcon(
                        SystemIcons.trash2,
                        size: 16,
                        color: GardenColors.of(context).danger,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Delete drive',
                        style: TextStyle(
                          color: GardenColors.of(context).danger,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ],
  );
}
