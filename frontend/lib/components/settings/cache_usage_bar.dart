import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../model/cache_usage.dart';

class CacheUsageBar extends StatelessWidget {
  const CacheUsageBar({super.key, required this.usage});
  final CacheUsage usage;

  static String bytes(int value) {
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KiB';
    if (value < CacheUsage.gib) {
      return '${(value / (1024 * 1024)).toStringAsFixed(1)} MiB';
    }
    return '${(value / CacheUsage.gib).toStringAsFixed(1)} GiB';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Text(
            '${bytes(usage.usedBytes!)} used',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            '${bytes(usage.limitBytes)} limit',
            style: TextStyle(
              fontSize: 12,
              color: GardenColors.of(context).secondary,
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: usage.fraction,
          minHeight: 8,
          color: GardenColors.of(context).ink,
          backgroundColor: GardenColors.of(context).border,
          semanticsLabel: 'Streaming cache usage',
          semanticsValue: '${(usage.fraction * 100).round()}%',
        ),
      ),
      SizedBox(height: 10),
      Text(
        '${usage.blocks} cached blocks · Shared across drives',
        style: TextStyle(
          fontSize: 12,
          color: GardenColors.of(context).secondary,
        ),
      ),
    ],
  );
}
