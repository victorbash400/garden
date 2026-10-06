import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/username_control.dart';
import '../components/settings/account_security_controls.dart';
import '../components/settings/settings_row.dart';
import '../components/settings/settings_action_row.dart';
import '../state/garden_controller.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (controller.security != null) ...[
        AccountSecurityControls(
          controller: controller.security!,
          account: controller.account!,
        ),
        const SizedBox(height: 20),
      ],
      SettingsGroup(
        children: [
          UsernameControl(controller: controller),
          SettingsRow(
            label: 'Email',
            value: SelectableText(controller.account!.email),
          ),
          SettingsActionRow(
            label: 'Sign out',
            onTap: controller.busy ? null : controller.signOut,
          ),
        ],
      ),
    ],
  );
}
