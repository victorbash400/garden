import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import 'toolbar_item_transition.dart';

class ToolbarGroup extends StatelessWidget {
  const ToolbarGroup({super.key, required this.children});
  final List<Widget?> children;
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
          for (var i = 0; i < children.length; i++)
            ToolbarItemTransition(
              key: ValueKey(i),
              child: children[i] == null
                  ? null
                  : Builder(
                      builder: (context) {
                        final first = children.indexWhere(
                          (child) => child != null,
                        );
                        final last = children.lastIndexWhere(
                          (child) => child != null,
                        );
                        final radius = BorderRadius.horizontal(
                          left: Radius.circular(i == first ? 17 : 6),
                          right: Radius.circular(i == last ? 17 : 6),
                        );
                        return Padding(
                          padding: EdgeInsets.only(left: i == first ? 0 : 2),
                          child: ClipRRect(
                            borderRadius: radius,
                            child: IconButtonTheme(
                              data: IconButtonThemeData(
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(
                                      borderRadius: radius,
                                    ),
                                  ),
                                ),
                              ),
                              child: children[i]!,
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    ),
  );
}
