import 'package:flutter/material.dart';

import '../../ui/garden_theme.dart';

class SettingsCategory extends StatelessWidget {
  const SettingsCategory({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    child: Material(
      color: selected ? GardenTheme.blue : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: ListTile(
        dense: true,
        minTileHeight: 42,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
        leading: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: .18)
                : const Color(0xFFE0E0E4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 17,
            color: selected ? Colors.white : GardenTheme.ink,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? Colors.white : GardenTheme.ink,
          ),
        ),
      ),
    ),
  );
}
