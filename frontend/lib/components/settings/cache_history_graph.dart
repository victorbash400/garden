import 'package:flutter/material.dart';

import '../../model/cache_sample.dart';
import 'cache_history_painter.dart';
import 'cache_usage_bar.dart';

class CacheHistoryGraph extends StatelessWidget {
  const CacheHistoryGraph({super.key, required this.samples});
  final List<CacheSample> samples;

  @override
  Widget build(BuildContext context) {
    final peak = samples.fold<int>(
      0,
      (peak, sample) => sample.bytes > peak ? sample.bytes : peak,
    );
    final maximum = peak < 1024 * 1024 ? 1024 * 1024 : (peak * 1.1).ceil();
    const labelStyle = TextStyle(fontSize: 11, color: Color(0xFF77777A));
    return Semantics(
      label: 'Cache usage history over five minutes',
      value: samples.isEmpty
          ? 'No measurements'
          : '${CacheUsageBar.bytes(samples.last.bytes)} at latest reading',
      child: Column(
        children: [
          Row(
            children: [
              const Text('Last 5 minutes', style: labelStyle),
              const Spacer(),
              Text(CacheUsageBar.bytes(maximum), style: labelStyle),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: CacheHistoryPainter(
                  samples: List.of(samples),
                  maximum: maximum,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Text('5 min ago', style: labelStyle),
              Spacer(),
              Text('Latest reading', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}
