import 'package:flutter/material.dart';

import '../scroll_edge.dart';

import '../../ui/garden_colors.dart';

import '../../state/files_controller.dart';
import 'column_node_row.dart';
import 'directory_drop_target.dart';
import 'node_context_menu.dart';

class DirectoryColumn extends StatelessWidget {
  const DirectoryColumn({
    super.key,
    required this.controller,
    required this.depth,
    required this.width,
  });
  final FilesController controller;
  final int depth;
  final double width;
  @override
  Widget build(BuildContext context) {
    final parent = depth == 0 ? 0 : controller.path[depth - 1].id!;
    final nodes = depth == controller.path.length
        ? controller.nodes
        : controller.folders.directory(parent);
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: depth < controller.path.length
              ? Border(
                  right: BorderSide(color: GardenColors.of(context).border),
                )
              : null,
        ),
        child: DirectoryDropTarget(
          controller: controller,
          parentId: parent,
          child: NodeContextMenu(
            controller: controller,
            parentId: parent,
            child: ScrollEdge(
              color: GardenColors.of(context).panel,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
      ),
    );
  }
}
