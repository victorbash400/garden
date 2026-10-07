import 'package:flutter/material.dart';

import '../scroll_edge.dart';
import '../../ui/garden_colors.dart';

import '../../state/files_controller.dart';
import 'file_grid_tile.dart';

class DirectoryGrid extends StatelessWidget {
  const DirectoryGrid({super.key, required this.controller});
  final FilesController controller;
  @override
  Widget build(BuildContext context) => ScrollEdge(
    color: GardenColors.of(context).panel,
    child: GridView.builder(
      padding: const EdgeInsets.all(18),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisExtent: 124,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: controller.nodes.length,
      itemBuilder: (_, index) =>
          FileGridTile(controller: controller, node: controller.nodes[index]),
    ),
  );
}
