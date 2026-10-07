import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow({super.key, required this.label, required this.value});
  final String label;
  final Widget value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final labelWidget = Text(label, style: const TextStyle(fontSize: 13));
        final control = DefaultTextStyle.merge(
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 13,
            color: GardenColors.of(context).secondary,
          ),
          child: value,
        );
        if (constraints.maxWidth < 380) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              labelWidget,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight, child: control),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: labelWidget),
            const SizedBox(width: 24),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: control),
            ),
          ],
        );
      },
    ),
  );
}
