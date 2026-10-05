import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        content: const Text(
          'This removes the drive for everyone. Its files are retained in storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete drive',
              style: TextStyle(color: Colors.red),
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
      SizedBox(
        width: 24,
        height: 28,
        child: IconButton(
          tooltip: 'New folder in ${drive.name}',
          padding: EdgeInsets.zero,
          onPressed: controller.busy ? null : () => createFolder(context),
          icon: const Icon(
            LucideIcons.plus,
            size: 14,
            color: Color(0xFF858581),
          ),
        ),
      ),
      SizedBox(
        width: 24,
        height: 28,
        child: PopupMenuButton<String>(
          tooltip: 'Actions for ${drive.name}',
          enabled: !controller.busy,
          padding: EdgeInsets.zero,
          icon: const Icon(
            LucideIcons.ellipsis,
            size: 15,
            color: Color(0xFF858581),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          elevation: 4,
          onSelected: (value) async {
            if (value == 'rename') await rename(context);
            if (value == 'folder' && context.mounted) {
              await createFolder(context);
            }
            if (value == 'delete' && context.mounted) await delete(context);
          },
          itemBuilder: (_) => [
            if (drive.role == 'Owner')
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(LucideIcons.squarePen, size: 16),
                    SizedBox(width: 10),
                    Text('Rename…'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'folder',
              child: Row(
                children: [
                  Icon(LucideIcons.folderPlus, size: 16),
                  SizedBox(width: 10),
                  Text('New folder'),
                ],
              ),
            ),
            if (drive.role == 'Owner')
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Delete drive', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
