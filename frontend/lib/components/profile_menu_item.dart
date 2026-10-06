import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({super.key, required this.icon, required this.label});
  final SystemIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SystemIcon(icon, size: 17, color: GardenColors.of(context).ink),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}
