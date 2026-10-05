import 'package:flutter/material.dart';

import 'settings_row.dart';

class BandwidthControl extends StatelessWidget {
  const BandwidthControl({
    super.key,
    required this.label,
    required this.value,
    required this.busy,
    required this.onChanged,
  });
  final String label;
  final int value;
  final bool busy;
  final ValueChanged<int> onChanged;
  static const rates = [0, 1, 2, 5, 10, 25, 50, 100];

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: label,
    value: Tooltip(
      message:
          'Average payload rate shared across app transfers and Finder drives.',
      child: Material(
        color: const Color(0xFFEDEDEE),
        borderRadius: BorderRadius.circular(7),
        clipBehavior: Clip.antiAlias,
        child: DropdownButton<int>(
          value: value,
          isDense: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(8),
          style: const TextStyle(fontSize: 13, color: Color(0xFF252528)),
          items: [
            if (!rates.any((rate) => rate * 1024 * 1024 == value))
              DropdownMenuItem(
                value: value,
                child: Text(
                  '${(value / (1024 * 1024)).toStringAsFixed(2)} MiB/s',
                ),
              ),
            for (final rate in rates)
              DropdownMenuItem(
                value: rate * 1024 * 1024,
                child: Text(rate == 0 ? 'Unlimited' : '$rate MiB/s'),
              ),
          ],
          onChanged: busy
              ? null
              : (rate) {
                  if (rate != null) onChanged(rate);
                },
        ),
      ),
    ),
  );
}
