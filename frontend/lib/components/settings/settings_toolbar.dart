import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsToolbar extends StatelessWidget {
  const SettingsToolbar({super.key, required this.label, required this.onBack});
  final String label;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 62,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back to drives',
          style: IconButton.styleFrom(
            backgroundColor: GardenColors.of(context).panel,
            minimumSize: Size(44, 32),
            padding: EdgeInsets.symmetric(horizontal: 10),
            shape: StadiumBorder(),
          ),
          onPressed: onBack,
          icon: SystemIcon(SystemIcons.chevronLeft, size: 21),
        ),
        SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
