import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WarningIcon extends StatelessWidget {
  const WarningIcon({super.key, this.size = 52});
  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/warning-yellow.svg',
    width: size,
    height: size,
    excludeFromSemantics: true,
  );
}
