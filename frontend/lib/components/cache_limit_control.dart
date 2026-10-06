import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class CacheLimitControl extends StatefulWidget {
  const CacheLimitControl({
    super.key,
    required this.limit,
    required this.busy,
    required this.onSave,
  });
  final int limit;
  final bool busy;
  final ValueChanged<int> onSave;
  @override
  State<CacheLimitControl> createState() => _CacheLimitControlState();
}

class _CacheLimitControlState extends State<CacheLimitControl> {
  late double value = widget.limit.toDouble();
  @override
  void didUpdateWidget(CacheLimitControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.limit != widget.limit || oldWidget.busy && !widget.busy) {
      value = widget.limit.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Text(
            'Cache limit',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Spacer(),
          Text(
            value.round() == 0 ? 'No disk cache' : '${value.round()} GiB',
            style: TextStyle(
              fontSize: 13,
              color: GardenColors.of(context).secondary,
            ),
          ),
        ],
      ),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          overlayShape: SliderComponentShape.noOverlay,
          overlayColor: Colors.transparent,
          trackHeight: 3,
          tickMarkShape: SliderTickMarkShape.noTickMark,
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
          activeTrackColor: GardenColors.of(context).ink,
          inactiveTrackColor: GardenColors.of(context).border,
          thumbColor: GardenColors.of(context).ink,
        ),
        child: Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: widget.busy
              ? null
              : (next) => setState(() => value = next),
          onChangeEnd: widget.busy
              ? null
              : (next) => widget.onSave(next.round()),
        ),
      ),
    ],
  );
}
