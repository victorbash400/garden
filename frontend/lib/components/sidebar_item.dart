import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });
  final int badge;
  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    child: Material(
      color: selected ? GardenColors.of(context).selection : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              icon,
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              if (badge > 0)
                Badge(
                  backgroundColor: GardenColors.of(context).accent,
                  textColor: GardenColors.of(context).onAccent,
                  label: Text('$badge'),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
