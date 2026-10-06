import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../model/garden_info.dart';
import '../ui/garden_colors.dart';
import 'garden_button.dart';

class GardenRow extends StatelessWidget {
  const GardenRow({super.key, required this.garden, this.onConnect});
  final GardenInfo garden;
  final VoidCallback? onConnect;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: GardenColors.of(context).divider),
      ),
    ),
    child: Row(
      children: [
        SystemIcon(
          SystemIcons.hardDrive,
          size: 30,
          color: GardenColors.of(context).ink,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(garden.name, style: TextStyle(fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text(
                '${garden.members} members · ${garden.role}',
                style: TextStyle(
                  fontSize: 12,
                  color: GardenColors.of(context).secondary,
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
