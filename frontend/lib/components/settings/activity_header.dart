import 'package:flutter/material.dart';

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
            style: const TextStyle(fontSize: 11, color: Color(0xFF777773)),
          ),
        );
        return Row(
          children: [
            const SizedBox(width: 31),
            const Expanded(
              child: Text(
                'File',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            cell('Action', 92),
            if (wide) cell('Drive', 90),
            if (wide) cell('Source', 112),
            cell('Time', 66),
            const SizedBox(width: 9),
          ],
        );
      },
    ),
  );
}
