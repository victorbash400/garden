import 'package:flutter/material.dart';

import '../../state/files_controller.dart';
import 'column_node_row.dart';
import 'directory_drop_target.dart';
import 'node_context_menu.dart';

class DirectoryColumn extends StatelessWidget {
  const DirectoryColumn({
    super.key,
    required this.controller,
    required this.depth,
  });
  final FilesController controller;
  final int depth;
  @override
  Widget build(BuildContext context) {
    final parent = depth == 0 ? 0 : controller.path[depth - 1].id!;
    final nodes = depth == controller.path.length
        ? controller.nodes
        : controller.folders.directory(parent);
    return SizedBox(
      width: 240,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Color(0xFFE8E8EB))),
        ),
        child: DirectoryDropTarget(
          controller: controller,
          parentId: parent,
          child: NodeContextMenu(
            controller: controller,
            parentId: parent,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              itemCount: nodes.length,
              itemBuilder: (_, index) => ColumnNodeRow(
                controller: controller,
                node: nodes[index],
                depth: depth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
