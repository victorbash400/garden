import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

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
    final labelStyle = TextStyle(
      fontSize: 11,
      color: GardenColors.of(context).secondary,
    );
    return Semantics(
      label: 'Cache usage history over five minutes',
      value: samples.isEmpty
          ? 'No measurements'
          : '${CacheUsageBar.bytes(samples.last.bytes)} at latest reading',
      child: Column(
        children: [
          Row(
            children: [
              Text('Last 5 minutes', style: labelStyle),
              Spacer(),
              Text(CacheUsageBar.bytes(maximum), style: labelStyle),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: CacheHistoryPainter(
                  samples: List.of(samples),
                  maximum: maximum,
                  accent: GardenColors.of(context).accent,
                  gridColor: GardenColors.of(context).border,
                ),
              ),
            ),
          ),
          SizedBox(height: 6),
          Row(
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
