import 'package:flutter/material.dart';

import 'garden_mark.dart';
import '../ui/garden_theme.dart';

class AccountBrand extends StatelessWidget {
  const AccountBrand({super.key, this.color = GardenTheme.ink});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GardenMark(size: 24, color: color),
      const SizedBox(width: 9),
      Text(
        'Garden',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    ],
  );
}
