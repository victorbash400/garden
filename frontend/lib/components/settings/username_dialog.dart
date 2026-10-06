import 'package:flutter/material.dart';

import '../../state/garden_controller.dart';
import '../../utils/error_message.dart';
import '../garden_field.dart';
import '../error_notice.dart';
import 'settings_inline_button.dart';

class UsernameDialog extends StatefulWidget {
  const UsernameDialog({super.key, required this.controller});
  final GardenController controller;
  @override
  State<UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<UsernameDialog> {
  late final input = TextEditingController(
    text: widget.controller.account!.username,
  );
  bool busy = false;
  String? error;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.controller.setUsername(input.text);
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
  Widget build(BuildContext context) => AlertDialog(
    content: SizedBox(
      width: 340,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GardenField(
            label: 'Username',
            controller: input,
            enabled: !busy,
            autofocus: true,
            onSubmitted: (_) {
              if (!busy) save();
            },
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
        label: busy ? 'Saving…' : 'Save',
        primary: true,
        onPressed: busy ? null : save,
      ),
    ],
  );
}
