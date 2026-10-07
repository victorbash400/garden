import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import 'system_icon.dart';

class WarningIcon extends StatelessWidget {
  const WarningIcon({super.key, this.size = 52});
  final double size;

  @override
  Widget build(BuildContext context) => SystemIcon(
    SystemIcons.triangleAlert,
    size: size,
    color: GardenColors.of(context).danger,
  );
}
