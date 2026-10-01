import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ui/garden_theme.dart';

class GardenMark extends StatelessWidget {
  const GardenMark({super.key, this.size = 20});
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/garden.svg',
    width: size,
    height: size,
    colorFilter: const ColorFilter.mode(GardenTheme.ink, BlendMode.srcIn),
    semanticsLabel: 'Garden',
  );
}
