import 'package:flutter/material.dart';

import '../settings/settings_picker.dart';

class ThemeFontControl extends StatelessWidget {
  const ThemeFontControl({
    super.key,
    required this.font,
    required this.onChanged,
  });
  final String? font;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => SettingsPicker<String>(
    width: 112,
    value: font ?? '.AppleSystemUIFont',
    items: [
      for (final entry in const {
        '.AppleSystemUIFont': 'System',
        'Geist': 'Geist',
        'Inter': 'Inter',
      }.entries)
        DropdownMenuItem(value: entry.key, child: Text(entry.value)),
    ],
    onChanged: onChanged == null ? null : (value) => onChanged!(value!),
  );
}
