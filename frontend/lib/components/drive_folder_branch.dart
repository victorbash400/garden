import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/files_controller.dart';
import 'sidebar_item.dart';

class DriveFolderBranch extends StatelessWidget {
  const DriveFolderBranch({
    super.key,
    required this.controller,
    required this.parentId,
    required this.onNavigate,
    this.depth = 1,
  });
  final FilesController controller;
  final int parentId;
  final int depth;
  final VoidCallback onNavigate;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final folder in controller.folders.children(parentId)) ...[
        Padding(
          padding: EdgeInsets.only(left: depth * 12),
          child: SidebarItem(
            icon: LucideIcons.folder,
            label: folder.name,
            selected: controller.parentId == folder.id,
            onTap: controller.busy
                ? null
                : () async {
                    await controller.openFolder(folder);
                    onNavigate();
                  },
          ),
        ),
        if (controller.path.any((node) => node.id == folder.id))
          DriveFolderBranch(
            controller: controller,
            parentId: folder.id!,
            depth: depth + 1,
            onNavigate: onNavigate,
          ),
      ],
    ],
  );
}
