import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../model/account_info.dart';
import '../../state/account_security_controller.dart';
import 'settings_group.dart';
import 'settings_row.dart';
import 'passkey_row.dart';
import 'touch_id_control.dart';

class AccountSecurityControls extends StatefulWidget {
  const AccountSecurityControls({
    super.key,
    required this.controller,
    required this.account,
  });
  final AccountSecurityController controller;
  final AccountInfo account;
  @override
  State<AccountSecurityControls> createState() =>
      _AccountSecurityControlsState();
}

class _AccountSecurityControlsState extends State<AccountSecurityControls> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Future<void> _remove(UuidValue id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove passkey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.controller.removePasskey(id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final security = widget.controller;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsGroup(
            children: [
              SettingsRow(
                label: 'Passkeys',
                value: TextButton(
                  onPressed: !security.configured || security.busy
                      ? null
                      : () => security.addPasskey(widget.account),
                  child: const Text('Add passkey'),
                ),
              ),
              for (final key in security.keys)
                PasskeyRow(
                  createdAt: key.createdAt,
                  onRemove: security.busy ? null : () => _remove(key.id),
                ),
              TouchIdControl(
                value: security.touchId,
                available: security.configured && security.available,
                configured: security.configured,
                onChanged: security.busy
                    ? null
                    : (value) => security.setTouchId(value, widget.account),
              ),
            ],
          ),
          if (!security.configured && !security.busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Passkeys and Touch ID require Apple signing setup.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          if (security.busy)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Please wait', style: TextStyle(fontSize: 12)),
            ),
          if (security.error != null || security.status != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                security.error ?? security.status!,
                style: TextStyle(
                  fontSize: 12,
                  color: security.error == null
                      ? null
                      : const Color(0xFFB23D3D),
                ),
              ),
            ),
        ],
      );
    },
  );
}
