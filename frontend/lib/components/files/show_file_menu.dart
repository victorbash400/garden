import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../native/file_context_menu.dart';
import '../../services/files/text_file_type.dart';
import '../../state/files_controller.dart';
import '../../ui/garden_colors.dart';
import 'file_actions.dart';
import 'node_menu_items.dart';

Future<void> showFileMenu(
  BuildContext context,
  FilesController controller, {
  FileNode? node,
  int? parentId,
  Offset? position,
}) async {
  final actions = FileActions(context, controller);
  if (node != null) controller.select(node);
  try {
    final String? action;
    final origin =
        position ??
        (context.findRenderObject()! as RenderBox).localToGlobal(Offset.zero);
    if (FileContextMenu.available) {
      action = await FileContextMenu.show(
        node: node,
        canWrite: controller.canWrite,
        canPreview: controller.previewFile != null,
        canShare: controller.canWrite && controller.shareNode != null,
        canOpenWith: controller.openFileWith != null,
        busy: controller.busy,
        importing: controller.imports.busy,
        editableText: node != null && isTextFile(node.name),
        x: origin.dx,
        y: origin.dy,
      );
    } else {
      final overlay =
          Overlay.of(context).context.findRenderObject()! as RenderBox;
      action = await showMenu<String>(
        context: context,
        elevation: 1,
        color: GardenColors.of(context).panel,
        surfaceTintColor: Colors.transparent,
        position: RelativeRect.fromRect(
          origin & Size.zero,
          Offset.zero & overlay.size,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: GardenColors.of(context).border),
        ),
        items: node == null
            ? [
                PopupMenuItem(
                  value: 'folder',
                  enabled: !controller.busy,
                  height: 30,
                  child: const Text('New folder…'),
                ),
                PopupMenuItem(
                  value: 'file',
                  enabled: !controller.busy,
                  height: 30,
                  child: const Text('New text file…'),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'import',
                  enabled: !controller.imports.busy,
                  height: 30,
                  child: const Text('Import files…'),
                ),
              ]
            : nodeMenuItems(
                node,
                canWrite: controller.canWrite,
                canPreview: controller.previewFile != null,
                canShare: controller.canWrite && controller.shareNode != null,
              ),
      );
    }
    if (action == null || !context.mounted) return;
    if (node != null) {
      await actions.perform(node, action);
    } else if (action == 'import') {
      await actions.import(parentId: parentId);
    } else {
      await actions.create(action, parentId: parentId);
    }
  } catch (failure) {
    controller.reportError(failure);
  }
}
