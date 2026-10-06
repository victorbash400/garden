import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import 'garden_mark.dart';

class AppTile extends StatelessWidget {
  const AppTile({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 106,
    height: 106,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GardenColors.of(context).panel,
          GardenColors.of(context).panel,
        ],
      ),
      borderRadius: BorderRadius.circular(27),
      border: Border.all(color: GardenColors.of(context).border),
      boxShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Center(child: GardenMark(size: 44)),
  );
}
