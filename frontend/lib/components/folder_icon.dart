import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import 'system_icon.dart';

class FolderIcon extends StatelessWidget {
  const FolderIcon({super.key, this.open = false, this.size = 24});
  final bool open;
  final double size;

  @override
  Widget build(BuildContext context) => SystemIcon(
    open ? SystemIcons.folderOpen : SystemIcons.folder,
    size: size,
    color: GardenColors.of(context).ink,
  );
}
