import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.label,
    required this.onTap,
  });
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    minTileHeight: 54,
    onTap: onTap,
    title: Text(
      label,
      style: TextStyle(fontSize: 13, color: GardenColors.of(context).danger),
    ),
  );
}
