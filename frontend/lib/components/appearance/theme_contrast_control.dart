import 'package:flutter/material.dart';

class ThemeContrastControl extends StatefulWidget {
  const ThemeContrastControl({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final int value;
  final ValueChanged<int>? onChanged;
  @override
  State<ThemeContrastControl> createState() => _ThemeContrastControlState();
}

class _ThemeContrastControlState extends State<ThemeContrastControl> {
  double? editing;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Row(
      children: [
        Expanded(
          child: Slider(
            value: editing ?? widget.value.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: '${(editing ?? widget.value).round()}',
            onChanged: widget.onChanged == null
                ? null
                : (value) => setState(() => editing = value),
            onChangeEnd: (value) {
              setState(() => editing = null);
              widget.onChanged?.call(value.round());
            },
          ),
        ),
        SizedBox(
          width: 28,
          child: Text('${(editing ?? widget.value).round()}'),
        ),
      ],
    ),
  );
}
