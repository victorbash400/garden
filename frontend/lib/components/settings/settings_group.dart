import 'package:flutter/material.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFAFAFA),
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE5E5E5)),
    ),
    child: Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE9E9EC)),
            ),
          children[i],
        ],
      ],
    ),
  );
}
