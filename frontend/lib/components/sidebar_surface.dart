import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class SidebarSurface extends StatelessWidget {
  const SidebarSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: MediaQuery.sizeOf(context).width < 800 ? 200 : 240,
    decoration: BoxDecoration(
      color: GardenColors.of(context).sidebar,
      border: Border(
        right: BorderSide(color: GardenColors.of(context).sidebarBorder),
      ),
    ),
    child: child,
  );
}
