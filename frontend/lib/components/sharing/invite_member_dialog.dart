import '../error_notice.dart';
import '../garden_field.dart';

import 'package:flutter/material.dart';

import '../settings/settings_picker.dart';
import '../settings/settings_row.dart';

import '../../services/sharing/drive_sharing_service.dart';
import '../../utils/error_message.dart';

class InviteMemberDialog extends StatefulWidget {
  const InviteMemberDialog({
    super.key,
    required this.service,
    required this.driveId,
    required this.owner,
  });
  final DriveSharingService service;
  final int driveId;
  final bool owner;
  @override
  State<InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<InviteMemberDialog> {
  final email = TextEditingController();
  String role = 'Viewer';
  String? error;
  bool busy = false;
  bool get canInvite => !busy && email.text.trim().isNotEmpty;
  @override
  void initState() {
    super.initState();
    email.addListener(emailChanged);
  }

  void emailChanged() => setState(() {});

  @override
  void dispose() {
    email.removeListener(emailChanged);
    email.dispose();
    super.dispose();
  }

  Future<void> invite() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final invitation = await widget.service.invite(
        widget.driveId,
        email.text,
        role,
      );
      if (mounted) Navigator.pop(context, invitation);
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Invite to drive'),
    content: SizedBox(
      width: 360,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GardenField(
            label: 'Email',
            controller: email,
            autofocus: true,
            enabled: !busy,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) {
              if (canInvite) invite();
            },
          ),
          const SizedBox(height: 16),
          SettingsRow(
            label: 'Permission',
            value: SettingsPicker<String>(
              value: role,
              items: [
                for (final value in [
                  'Viewer',
                  'Editor',
                  if (widget.owner) 'Manager',
                ])
                  DropdownMenuItem(value: value, child: Text(value)),
              ],
              onChanged: busy ? null : (value) => setState(() => role = value!),
            ),
          ),
          if (error != null) ...[ErrorNotice(message: error!)],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: canInvite ? invite : null,
        child: Text(busy ? 'Inviting…' : 'Invite'),
      ),
    ],
  );
}
