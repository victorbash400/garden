import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/files_controller.dart';
import '../list_row.dart';
import 'file_actions.dart';
import 'node_context_menu.dart';
import 'node_icon.dart';

class ColumnNodeRow extends StatelessWidget {
  const ColumnNodeRow({
    super.key,
    required this.controller,
    required this.node,
    required this.depth,
  });
  final FilesController controller;
  final FileNode node;
  final int depth;
  @override
  Widget build(BuildContext context) {
    final active =
        controller.path.any((folder) => folder.id == node.id) ||
        controller.selected?.id == node.id;
    return NodeContextMenu(
      controller: controller,
      node: node,
      child: ListRow(
        selected: active,
        onTap: () async {
          if (node.kind == NodeKind.folder) {
            await controller.openFolder(node);
          } else {
            await controller.goTo(depth);
            if (controller.path.length == depth) controller.select(node);
          }
        },
        onDoubleTap: node.kind == NodeKind.folder
            ? null
            : () => FileActions(context, controller).open(node),
        child: SizedBox(
          height: 29,
          child: Row(
            children: [
              const SizedBox(width: 6),
              NodeIcon(node: node, size: 20, open: active),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (node.kind == NodeKind.folder)
                const Icon(
                  LucideIcons.chevronRight,
                  size: 12,
                  color: Color(0xFF888884),
                ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}
