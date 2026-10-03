import 'package:flutter/material.dart';

import '../../native/system_setup.dart';
import '../../state/native_setup_controller.dart';
import 'settings_row.dart';
import 'settings_inline_button.dart';

class LoginItemRow extends StatelessWidget {
  const LoginItemRow({super.key, required this.controller});
  final NativeSetupController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.status?.launchAtLogin;
    final enabled =
        state == LoginItemState.enabled ||
        state == LoginItemState.requiresApproval;
    final label = switch (state) {
      LoginItemState.enabled => 'On',
      LoginItemState.disabled => 'Off',
      LoginItemState.requiresApproval => 'Approval required',
      LoginItemState.notFound => 'Registration missing',
      LoginItemState.unsupported => 'Requires macOS 13',
      LoginItemState.unknown => 'Unknown status',
      null => 'Checking',
    };
    return SettingsRow(
      label: 'Launch at login',
      value: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Text(label)),
          if (state == LoginItemState.requiresApproval)
            SettingsInlineButton(
              onPressed: controller.busy ? null : controller.openLoginSettings,
              label: 'Approve…',
            ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: enabled,
            onChanged:
                controller.busy ||
                    state == null ||
                    state == LoginItemState.unsupported ||
                    state == LoginItemState.unknown
                ? null
                : controller.setLaunchAtLogin,
          ),
        ],
      ),
    );
  }
}
