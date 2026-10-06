import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class ActivityHeader extends StatelessWidget {
  const ActivityHeader({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 32,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 650;
        Widget cell(String text, double width) => SizedBox(
          width: width,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: GardenColors.of(context).secondary,
            ),
          ),
        );
        return Row(
          children: [
            SizedBox(width: 31),
            Expanded(
              child: Text(
                'File',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(width: 12),
            cell('Action', 92),
            if (wide) cell('Drive', 90),
            if (wide) cell('Source', 112),
            cell('Time', 66),
            SizedBox(width: 9),
          ],
        );
      },
    ),
  );
}
