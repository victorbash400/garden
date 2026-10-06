import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import 'file_actions.dart';
import 'node_menu_items.dart';
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
    onSecondaryTapDown:
        controller.busy || (node == null && !controller.canWrite)
        ? null
        : (details) async {
            final actions = FileActions(context, controller);
            if (node != null) controller.select(node);
            final overlay =
                Overlay.of(context).context.findRenderObject()! as RenderBox;
            final action = await showMenu<String>(
              context: context,
              elevation: 1,
              color: GardenColors.of(context).panel,
              surfaceTintColor: Colors.transparent,
              position: RelativeRect.fromRect(
                Rect.fromLTWH(
                  details.globalPosition.dx,
                  details.globalPosition.dy,
                  0,
                  0,
                ),
                Offset.zero & overlay.size,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: GardenColors.of(context).border),
              ),
              items: node == null
                  ? [
                      PopupMenuItem(
                        value: 'folder',
                        child: Text('New folder…'),
                      ),
                      PopupMenuItem(
                        value: 'file',
                        child: Text('New text file…'),
                      ),
                      PopupMenuItem(
                        value: 'import',
                        enabled: !controller.imports.busy,
                        child: Text('Import files…'),
                      ),
                    ]
                  : nodeMenuItems(node!, canWrite: controller.canWrite),
            );
            if (action == null || !context.mounted) return;
            if (node != null) {
              await actions.perform(node!, action);
            } else if (action == 'import') {
              await actions.import(parentId: parentId);
            } else {
              await actions.create(action, parentId: parentId);
            }
          },
    child: NodeDragSurface(
      controller: controller,
      driveId: controller.drive!.id,
      node: node,
      parentId: node == null ? (parentId ?? controller.parentId) : null,
      child: child,
    ),
  );
}
