import 'package:flutter/material.dart';

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
          Text('${bytes(usage.usedBytes!)} used'),
          const Spacer(),
          Text('${bytes(usage.limitBytes)} limit'),
        ],
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: usage.fraction,
          minHeight: 8,
          color: const Color(0xFF313133),
          backgroundColor: const Color(0xFFE8E8EA),
          semanticsLabel: 'Streaming cache usage',
          semanticsValue: '${(usage.fraction * 100).round()}%',
        ),
      ),
      const SizedBox(height: 10),
      Text(
        '${usage.blocks} cached blocks · Shared across drives',
        style: const TextStyle(fontSize: 12, color: Color(0xFF77777A)),
      ),
    ],
  );
}
