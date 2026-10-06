import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.label, required this.value});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        Text(label, style: TextStyle(fontSize: 13)),
        SizedBox(width: 24),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyMedium!.fontFamily,
                fontSize: 13,
                color: GardenColors.of(context).secondary,
              ),
              child: value,
            ),
          ),
        ),
      ],
    ),
  );
}
