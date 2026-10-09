import 'package:flutter/material.dart';

import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import 'show_file_menu.dart';
import 'node_drag_surface.dart';

class NodeContextMenu extends StatelessWidget {
  const NodeContextMenu({
    super.key,
    required this.controller,
    required this.child,
    this.node,
    this.parentId,
  });
  final FilesController controller;
  final FileNode? node;
  final int? parentId;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onSecondaryTapUp: node == null && !controller.canWrite
        ? null
        : (details) => showFileMenu(
            context,
            controller,
            node: node,
            parentId: parentId,
            position: details.globalPosition,
          ),
    child: NodeDragSurface(
      controller: controller,
      driveId: controller.drive!.id,
      node: node,
      parentId: node == null ? (parentId ?? controller.parentId) : null,
      child: child,
    ),
  );
}
