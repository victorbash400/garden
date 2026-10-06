import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) {
    final unread = controller.notifications?.unread ?? 0;
    return IconButton(
      tooltip: unread == 0 ? 'Notifications' : '$unread unread notifications',
      onPressed: () {
        controller.selectSettings(SettingsSection.notifications);
        controller.navigate(GardenPage.settings);
      },
      style: IconButton.styleFrom(
        fixedSize: const Size(36, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Badge(
        isLabelVisible: unread > 0,
        smallSize: 5,
        backgroundColor: Theme.of(context).colorScheme.error,
        child: const SystemIcon(SystemIcons.bell, size: 17),
      ),
    );
  }
}
