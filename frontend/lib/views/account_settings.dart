import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/account_identity.dart';
import '../components/settings/settings_action_row.dart';
import '../state/garden_controller.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      AccountIdentity(email: controller.account!.email),
      SettingsGroup(
        children: [
          SettingsActionRow(
            label: 'Sign out',
            onTap: controller.busy ? null : controller.signOut,
          ),
        ],
      ),
    ],
  );
}
