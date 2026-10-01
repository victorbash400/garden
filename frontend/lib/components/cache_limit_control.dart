import 'package:flutter/material.dart';

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
          const Text('Cache limit'),
          const Spacer(),
          Text('${value.round()} GiB'),
        ],
      ),
      Slider(
        value: value,
        min: 1,
        max: 100,
        divisions: 99,
        onChanged: widget.busy ? null : (next) => setState(() => value = next),
        onChangeEnd: widget.busy ? null : (next) => widget.onSave(next.round()),
      ),
    ],
  );
}
