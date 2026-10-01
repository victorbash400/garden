import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/files_controller.dart';
import 'tree_row.dart';

class TreeFileRow extends StatelessWidget {
  const TreeFileRow({
    super.key,
    required this.node,
    required this.controller,
    required this.depth,
    required this.onNavigate,
  });
  final FileNode node;
  final FilesController controller;
  final int depth;
  final VoidCallback onNavigate;
  @override
  Widget build(BuildContext context) => TreeRow(
    label: node.name,
    icon: LucideIcons.file,
    depth: depth,
    selected: controller.selected?.id == node.id,
    onOpen: controller.busy
        ? null
        : () async {
            final path = controller.folders.pathTo(node);
            if (path.length == 1) {
              await controller.goTo(0);
            } else {
              await controller.openFolder(path[path.length - 2]);
            }
            if (controller.error == null) controller.select(node);
            onNavigate();
          },
  );
}
