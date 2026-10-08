import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import '../../utils/error_message.dart';
import '../error_notice.dart';
import '../garden_field.dart';
import 'settings_inline_button.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key, required this.controller});
  final GardenController controller;
  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final email = TextEditingController();
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    email.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> remove() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.controller.deleteAccount(email.text);
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) {
        setState(() {
          busy = false;
          error = errorMessage(failure);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: AlertDialog(
      title: const Text('Delete account?'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Permanently deletes your owned drives and their cloud files, including shared drives you own. Files and messages in drives owned by others remain. Your email can be reused after deletion finishes.',
            ),
            const SizedBox(height: 20),
            GardenField(
              label: 'Enter your account email',
              controller: email,
              enabled: !busy,
            ),
            if (error != null)
              ErrorNotice(
                message: error!,
                onDismiss: () => setState(() => error = null),
              ),
          ],
        ),
      ),
      actions: [
        SettingsInlineButton(
          label: 'Cancel',
          onPressed: busy ? null : () => Navigator.pop(context),
        ),
        SettingsInlineButton(
          label: busy ? 'Deleting…' : 'Delete account',
          primary: true,
          onPressed:
              busy ||
                  email.text.trim().toLowerCase() !=
                      widget.controller.account?.email.toLowerCase()
              ? null
              : remove,
        ),
      ],
    ),
  );
}
