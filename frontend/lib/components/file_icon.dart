import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import 'system_icon.dart';

class FileIcon extends StatelessWidget {
  const FileIcon({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SystemIcon(
    SystemIcons.file,
    size: size,
    color: color ?? GardenColors.of(context).ink,
  );
}
