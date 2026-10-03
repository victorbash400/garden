import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/files_controller.dart';
import 'toolbar_group.dart';

class FileViewSelector extends StatelessWidget {
  const FileViewSelector({super.key, required this.controller});
  final FilesController controller;
  @override
  Widget build(BuildContext context) => ToolbarGroup(
    children: [
      for (final mode in FileViewMode.values)
        SizedBox(
          width: 32,
          height: 32,
          child: IconButton(
            tooltip: switch (mode) {
              FileViewMode.grid => 'Grid view',
              FileViewMode.list => 'List view',
              FileViewMode.columns => 'Column view',
            },
            isSelected: controller.viewMode == mode,
            style: IconButton.styleFrom(
              backgroundColor: controller.viewMode == mode
                  ? const Color(0xFFE6E6E3)
                  : Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => controller.setViewMode(mode),
            icon: Icon(switch (mode) {
              FileViewMode.grid => LucideIcons.layoutGrid,
              FileViewMode.list => LucideIcons.list,
              FileViewMode.columns => LucideIcons.columns3,
            }, size: 16),
          ),
        ),
    ],
  );
}
