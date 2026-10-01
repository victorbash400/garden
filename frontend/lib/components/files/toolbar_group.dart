import 'package:flutter/material.dart';

class ToolbarGroup extends StatelessWidget {
  const ToolbarGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFFF9F9F9),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const SizedBox(
                  height: 26,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Color(0xFFE1E1DD),
                  ),
                ),
              children[i],
            ],
          ],
        ),
      ),
    ),
  );
}
