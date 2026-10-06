import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/system_icons.dart';
import '../ui/garden_colors.dart';
export '../ui/system_icons.dart';

class SystemIcon extends StatelessWidget {
  const SystemIcon(this.icon, {super.key, this.size, this.color});
  final SystemIcons icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final ink = color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;
    final colors = Theme.of(context).extension<GardenColors>();
    final iconColor = colors != null && ink == colors.ink ? colors.icon : ink;
    final opacity = theme.opacity ?? 1;
    final dimension = size ?? theme.size ?? 18;
    // System UIcons includes more canvas padding than Lucide.
    final drawingSize = dimension * 1.25;
    return SizedBox.square(
      dimension: dimension,
      child: OverflowBox(
        minWidth: drawingSize,
        maxWidth: drawingSize,
        minHeight: drawingSize,
        maxHeight: drawingSize,
        child: SvgPicture.asset(
          icon.asset,
          width: drawingSize,
          height: drawingSize,
          excludeFromSemantics: true,
          colorFilter: ColorFilter.mode(
            iconColor.withValues(alpha: iconColor.a * opacity),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
