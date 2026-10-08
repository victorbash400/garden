import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/garden_colors.dart';

enum LucideIcons { house, inbox }

class LucideIcon extends StatelessWidget {
  const LucideIcon(this.icon, {super.key, this.size = 18});

  final LucideIcons icon;
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/lucide-${icon.name}.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
    colorFilter: ColorFilter.mode(
      GardenColors.of(context).icon,
      BlendMode.srcIn,
    ),
  );
}
