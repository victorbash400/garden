import 'package:flutter/material.dart';

import 'settings_row.dart';

class TouchIdControl extends StatelessWidget {
  const TouchIdControl({
    super.key,
    required this.value,
    required this.available,
    required this.configured,
    required this.onChanged,
  });
  final bool configured;
  final bool value;
  final bool available;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Touch ID on this Mac',
    value: available
        ? Switch.adaptive(value: value, onChanged: onChanged)
        : Text(
            configured
                ? 'Set up in System Settings'
                : 'Apple signing setup required',
          ),
  );
}
