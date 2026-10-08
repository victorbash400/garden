import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import 'settings_inline_button.dart';
import 'settings_row.dart';

class SetupStepRow extends StatelessWidget {
  const SetupStepRow({
    super.key,
    required this.number,
    required this.label,
    required this.complete,
    required this.action,
    required this.onPressed,
  });

  final int number;
  final String label;
  final bool complete;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: '$number. $label',
    value: Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        Text(
          complete ? 'Done' : 'Not complete',
          style: TextStyle(color: GardenColors.of(context).secondary),
        ),
        if (onPressed != null) ...[
          SettingsInlineButton(label: action, onPressed: onPressed),
        ],
      ],
    ),
  );
}
