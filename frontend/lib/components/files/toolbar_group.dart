import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class ToolbarGroup extends StatelessWidget {
  const ToolbarGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: GardenColors.of(context).sidebar,
      border: Border.all(color: GardenColors.of(context).border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Builder(
              builder: (context) {
                final radius = BorderRadius.horizontal(
                  left: Radius.circular(i == 0 ? 17 : 6),
                  right: Radius.circular(i == children.length - 1 ? 17 : 6),
                );
                return ClipRRect(
                  borderRadius: radius,
                  child: IconButtonTheme(
                    data: IconButtonThemeData(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(borderRadius: radius),
                        ),
                      ),
                    ),
                    child: children[i],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    ),
  );
}
