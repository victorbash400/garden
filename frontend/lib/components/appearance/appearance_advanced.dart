import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../settings/settings_group.dart';
import '../settings/settings_row.dart';
import 'theme_contrast_control.dart';

class AppearanceAdvanced extends StatefulWidget {
  const AppearanceAdvanced({
    super.key,
    required this.contrast,
    required this.onChanged,
    required this.onReset,
  });
  final int contrast;
  final ValueChanged<int>? onChanged;
  final VoidCallback? onReset;
  @override
  State<AppearanceAdvanced> createState() => _AppearanceAdvancedState();
}

class _AppearanceAdvancedState extends State<AppearanceAdvanced> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => setState(() => expanded = !expanded),
            style: TextButton.styleFrom(
              foregroundColor: GardenColors.of(context).secondary,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Advanced'),
                const SizedBox(width: 6),
                SystemIcon(
                  expanded ? SystemIcons.chevronDown : SystemIcons.chevronRight,
                  size: 14,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: widget.onReset,
            style: TextButton.styleFrom(
              foregroundColor: GardenColors.of(context).secondary,
              padding: EdgeInsets.zero,
            ),
            child: const Text('Reset to default'),
          ),
        ],
      ),
      if (expanded) ...[
        const SizedBox(height: 8),
        SettingsGroup(
          children: [
            SettingsRow(
              label: 'Contrast',
              value: ThemeContrastControl(
                value: widget.contrast,
                onChanged: widget.onChanged,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}
