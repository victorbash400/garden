import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import 'username_dialog.dart';
import 'settings_inline_button.dart';
import 'settings_row.dart';

class UsernameControl extends StatelessWidget {
  const UsernameControl({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Username',
    value: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            controller.account!.username,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        SettingsInlineButton(
          label: 'Edit',
          onPressed: controller.busy
              ? null
              : () async {
                  await showDialog<void>(
                    context: context,
                    builder: (_) => UsernameDialog(controller: controller),
                  );
                },
        ),
      ],
    ),
  );
}
