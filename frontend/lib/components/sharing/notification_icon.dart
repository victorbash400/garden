import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key, required this.unread});
  final bool unread;

  @override
  Widget build(BuildContext context) => Semantics(
    label: unread ? 'Unread notification' : 'Read notification',
    child: SizedBox.square(
      dimension: 22,
      child: Stack(
        children: [
          Center(
            child: SystemIcon(
              SystemIcons.bell,
              size: 18,
              color: GardenColors.of(context).ink,
            ),
          ),
          if (unread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: GardenColors.of(context).accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: GardenColors.of(context).panel,
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
