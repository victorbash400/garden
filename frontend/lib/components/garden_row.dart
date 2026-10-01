import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../model/garden_info.dart';
import '../ui/garden_theme.dart';
import 'garden_button.dart';

class GardenRow extends StatelessWidget {
  const GardenRow({super.key, required this.garden, this.onConnect});
  final GardenInfo garden;
  final VoidCallback? onConnect;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE9E9EC))),
    ),
    child: Row(
      children: [
        const Icon(
          LucideIcons.hardDrive,
          size: 30,
          color: GardenTheme.secondary,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                garden.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${garden.members} members · ${garden.role}',
                style: const TextStyle(
                  fontSize: 12,
                  color: GardenTheme.secondary,
                ),
              ),
            ],
          ),
        ),
        GardenButton(label: 'Open', secondary: true, onPressed: onConnect),
      ],
    ),
  );
}
