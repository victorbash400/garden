import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../system_icon.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, this.group = false, this.size = 34});
  final bool group;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: GardenColors.of(context).selection,
      shape: BoxShape.circle,
    ),
    child: group
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SystemIcon(SystemIcons.userRound, size: size * .36),
              SystemIcon(SystemIcons.userRound, size: size * .36),
            ],
          )
        : SystemIcon(SystemIcons.userRound, size: size * .53),
  );
}
