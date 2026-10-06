import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../state/files_controller.dart';
import '../../ui/garden_colors.dart';

class HomeBreadcrumb extends StatelessWidget {
  const HomeBreadcrumb({
    super.key,
    required this.controller,
    required this.onHome,
  });
  final FilesController controller;
  final VoidCallback onHome;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _item(context, 'Home', onHome),
        SystemIcon(
          SystemIcons.chevronRight,
          size: 12,
          color: GardenColors.of(context).ink,
        ),
        _item(context, controller.drive!.name, () => controller.goTo(0)),
        for (var i = 0; i < controller.path.length; i++) ...[
          SystemIcon(
            SystemIcons.chevronRight,
            size: 12,
            color: GardenColors.of(context).ink,
          ),
          _item(context, controller.path[i].name, () => controller.goTo(i + 1)),
        ],
      ],
    ),
  );
  Widget _item(BuildContext context, String label, VoidCallback action) =>
      TextButton(
        onPressed: action,
        style: TextButton.styleFrom(
          foregroundColor: GardenColors.of(context).ink,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: Theme.of(context).textTheme.labelLarge!
              .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          overlayColor: GardenColors.of(context).hover,
        ),
        child: Text(label),
      );
}
