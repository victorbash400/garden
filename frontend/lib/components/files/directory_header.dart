import 'package:flutter/material.dart';

class DirectoryHeader extends StatelessWidget {
  const DirectoryHeader({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.only(left: 19, right: 58),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0xFFE6E6E6))),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(child: Text('Name')),
          if (constraints.maxWidth >= 480)
            SizedBox(width: 140, child: Text('Date modified')),
          SizedBox(width: 80, child: Text('Size', textAlign: TextAlign.right)),
          if (constraints.maxWidth >= 360)
            SizedBox(
              width: 90,
              child: Text('Kind', textAlign: TextAlign.right),
            ),
        ],
      ),
    ),
  );
}
