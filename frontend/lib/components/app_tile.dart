import 'package:flutter/material.dart';

import 'garden_mark.dart';

class AppTile extends StatelessWidget {
  const AppTile({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 106,
    height: 106,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Color(0xFFF4F4F6)],
      ),
      borderRadius: BorderRadius.circular(27),
      border: Border.all(color: const Color(0xFFE5E5E7)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 30,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: const Center(child: GardenMark(size: 44)),
  );
}
