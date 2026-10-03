import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/files_controller.dart';
import 'toolbar_group.dart';
import 'toolbar_button.dart';

class FileViewSelector extends StatelessWidget {
  const FileViewSelector({super.key, required this.controller});
  final FilesController controller;
  @override
  Widget build(BuildContext context) => ToolbarGroup(
    children: [
      for (final mode in FileViewMode.values)
        ToolbarButton(
          tooltip: switch (mode) {
            FileViewMode.grid => 'Grid view',
            FileViewMode.list => 'List view',
            FileViewMode.columns => 'Column view',
          },
          selected: controller.viewMode == mode,
          onPressed: () => controller.setViewMode(mode),
          icon: switch (mode) {
            FileViewMode.grid => LucideIcons.layoutGrid,
            FileViewMode.list => LucideIcons.list,
            FileViewMode.columns => LucideIcons.columns3,
          },
        ),
    ],
  );
}
