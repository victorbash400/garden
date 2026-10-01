import 'package:flutter/material.dart';

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
      style: const TextStyle(fontSize: 13, color: Color(0xFFB23D3D)),
    ),
  );
}
