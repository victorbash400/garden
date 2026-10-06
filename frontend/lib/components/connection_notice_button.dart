import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class ConnectionNoticeButton extends StatelessWidget {
  const ConnectionNoticeButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 32,
    child: IconButton(
      tooltip: 'Connection needs attention',
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Badge(
        backgroundColor: GardenColors.of(context).accent,
        child: SystemIcon(SystemIcons.bell, size: 17),
      ),
    ),
  );
}
