import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../model/appearance/theme_profile.dart';
import '../../ui/garden_colors.dart';

class ThemeColorControl extends StatefulWidget {
  const ThemeColorControl({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
  });
  final String label;
  final Color color;
  final ValueChanged<Color>? onChanged;
  @override
  State<ThemeColorControl> createState() => _ThemeColorControlState();
}

class _ThemeColorControlState extends State<ThemeColorControl> {
  late final input = TextEditingController(text: hexColor(widget.color));
  String? error;
  bool get edited => input.text != hexColor(widget.color);
  @override
  void didUpdateWidget(ThemeColorControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      input.text = hexColor(widget.color);
      error = null;
    }
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void apply() {
    try {
      final color = parseColor(input.text);
      setState(() => error = null);
      widget.onChanged?.call(color);
    } on FormatException catch (failure) {
      setState(() => error = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: error == null ? 154 : 220,
    child: Semantics(
      label: widget.label,
      child: TextField(
        controller: input,
        enabled: widget.onChanged != null,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => apply(),
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          errorText: error,
          errorMaxLines: 2,
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: GardenColors.of(context).border),
                ),
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            maxWidth: 28,
            maxHeight: 32,
          ),
          suffixIcon: edited
              ? IconButton(
                  tooltip: 'Apply ${widget.label.toLowerCase()}',
                  padding: EdgeInsets.zero,
                  onPressed: widget.onChanged == null ? null : apply,
                  icon: const SystemIcon(SystemIcons.check, size: 14),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: GardenColors.of(context).border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: GardenColors.of(context).border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: GardenColors.of(context).accent),
          ),
        ),
      ),
    ),
  );
}
