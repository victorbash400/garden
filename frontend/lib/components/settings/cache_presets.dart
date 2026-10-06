import 'package:flutter/material.dart';

import 'settings_picker.dart';

class CachePresets extends StatelessWidget {
  const CachePresets({super.key, required this.limit, required this.onChanged});
  final int limit;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final choices = {0, 10, 20, 50, 100, limit}.toList()..sort();
    return SettingsPicker<int>(
      value: limit,
      width: 140,
      items: [
        for (final size in choices)
          DropdownMenuItem(
            value: size,
            child: Text(size == 0 ? 'No disk cache' : '$size GiB'),
          ),
      ],
      onChanged: onChanged == null ? null : (value) => onChanged!(value!),
    );
  }
}
