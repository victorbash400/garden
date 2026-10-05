import 'hover_rename.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import '../list_row.dart';
import 'file_actions.dart';
import 'node_context_menu.dart';
import 'node_icon.dart';

class FileGridTile extends StatelessWidget {
  const FileGridTile({super.key, required this.controller, required this.node});
  final FilesController controller;
  final FileNode node;
  @override
  Widget build(BuildContext context) => HoverRename(
    onRename: controller.busy || !controller.canWrite
        ? null
        : () => FileActions(context, controller).perform(node, 'rename'),
    right: 4,
    child: NodeContextMenu(
      controller: controller,
      node: node,
      child: ListRow(
        selected: controller.selected?.id == node.id,
        onTap: () => controller.select(node),
        onDoubleTap: () => FileActions(context, controller).open(node),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NodeIcon(
                node: node,
                size: 56,
                open: controller.selected?.id == node.id,
              ),
              const SizedBox(height: 10),
              Text(
                node.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
