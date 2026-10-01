import 'package:flutter/material.dart';

class EmptyDirectory extends StatelessWidget {
  const EmptyDirectory({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'This folder is empty',
    child: LayoutBuilder(
      builder: (_, size) => Column(
        children: [
          for (var index = 0; index < (size.maxHeight / 32).floor(); index++)
            Container(
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: index.isEven ? const Color(0xFFF7F7F7) : Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
        ],
      ),
    ),
  );
}
