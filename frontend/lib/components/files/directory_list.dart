import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import 'file_actions.dart';
import 'file_row.dart';
import 'empty_directory.dart';
import 'node_context_menu.dart';

class DirectoryList extends StatelessWidget {
  const DirectoryList({super.key, required this.controller});
  final FilesController controller;
  @override
  Widget build(BuildContext context) {
    final actions = FileActions(context, controller);
    if (controller.nodes.isEmpty && !controller.busy) {
      return const EmptyDirectory();
    }
    return AbsorbPointer(
      absorbing: controller.busy,
      child: ListView.builder(
        itemCount: controller.nodes.length,
        itemBuilder: (_, index) {
          final FileNode node = controller.nodes[index];
          return NodeContextMenu(
            controller: controller,
            node: node,
            child: FileRow(
              node: node,
              striped: index.isEven,
              selected: controller.selected?.id == node.id,
              onSelect: () => controller.select(node),
              onOpen: () => actions.open(node),
              onAction: (action) => actions.perform(node, action),
            ),
          );
        },
      ),
    );
  }
}
