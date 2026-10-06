import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/garden_colors.dart';

class GardenMark extends StatelessWidget {
  const GardenMark({super.key, this.size = 20, this.color});
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/garden.svg',
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(
      color ?? GardenColors.of(context).ink,
      BlendMode.srcIn,
    ),
    semanticsLabel: 'Garden',
  );
}
