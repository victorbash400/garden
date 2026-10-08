import 'package:flutter/material.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/delete_account_dialog.dart';
import '../components/settings/username_control.dart';
import '../components/settings/account_security_controls.dart';
import '../components/settings/settings_row.dart';
import '../components/settings/settings_action_row.dart';
import '../components/settings/setup_checklist.dart';
import '../components/settings/settings_inline_button.dart';
import '../state/garden_controller.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: SettingsInlineButton(
          label: 'Open setup',
          onPressed: controller.openSetup,
        ),
      ),
      const SizedBox(height: 12),
      SetupChecklist(controller: controller),
      const SizedBox(height: 20),
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
            label: 'Delete account',
            onTap: controller.busy
                ? null
                : () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => DeleteAccountDialog(controller: controller),
                  ),
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
