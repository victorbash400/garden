import 'package:flutter/material.dart';

import '../../ui/garden_theme.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.label, required this.value});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 24),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'GoogleSans',
                fontSize: 13,
                color: GardenTheme.secondary,
              ),
              child: value,
            ),
          ),
        ),
      ],
    ),
  );
}
