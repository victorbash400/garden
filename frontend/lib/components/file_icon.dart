import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import 'system_icon.dart';

class FileIcon extends StatelessWidget {
  const FileIcon({super.key, this.size = 24, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return SystemIcon(
      SystemIcons.file,
      size: size,
      color: color == null || color == colors.ink ? colors.mix(.68) : color,
    );
  }
}
