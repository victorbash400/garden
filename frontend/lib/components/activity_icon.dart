import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ActivityIcon extends StatelessWidget {
  const ActivityIcon({super.key});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/activity.svg',
    width: 17,
    height: 17,
    colorFilter: const ColorFilter.mode(Color(0xFF555550), BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}
