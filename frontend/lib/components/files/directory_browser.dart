import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../state/files_controller.dart';
import 'directory_columns.dart';
import 'directory_drop_target.dart';
import 'directory_grid.dart';
import 'directory_header.dart';
import 'directory_list.dart';
import 'node_context_menu.dart';

class DirectoryBrowser extends StatelessWidget {
  const DirectoryBrowser({super.key, required this.controller});
  final FilesController controller;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (controller.viewMode == FileViewMode.list)
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 11,
            color: GardenColors.of(context).secondary,
          ),
          child: DirectoryHeader(),
        ),
      Expanded(
        child: controller.viewMode == FileViewMode.columns
            ? DirectoryColumns(controller: controller)
            : DirectoryDropTarget(
                controller: controller,
                child: NodeContextMenu(
                  controller: controller,
                  child: switch (controller.viewMode) {
                    FileViewMode.list => DirectoryList(controller: controller),
                    FileViewMode.grid => DirectoryGrid(controller: controller),
                    FileViewMode.columns => DirectoryColumns(
                      controller: controller,
                    ),
                  },
                ),
              ),
      ),
    ],
  );
}
