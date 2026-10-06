import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class EmptyDirectory extends StatelessWidget {
  const EmptyDirectory({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'This folder is empty',
    child: LayoutBuilder(
      builder: (_, size) => Column(
        children: [
          for (var index = 0; index < (size.maxHeight / 32).floor(); index++)
            Container(
              height: 32,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: index.isEven
                    ? GardenColors.of(context).stripe
                    : GardenColors.of(context).panel,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
        ],
      ),
    ),
  );
}
