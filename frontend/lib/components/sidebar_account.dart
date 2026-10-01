import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/garden_controller.dart';
import 'tree_row.dart';

class SidebarAccount extends StatelessWidget {
  const SidebarAccount({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => TreeRow(
    label: controller.account!.email,
    icon: LucideIcons.userRound,
    selected: false,
    onOpen: controller.busy
        ? null
        : () {
            controller.selectSettings(SettingsSection.account);
            controller.navigate(GardenPage.settings);
          },
  );
}
