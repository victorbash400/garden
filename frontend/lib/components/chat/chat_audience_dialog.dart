import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import '../settings/settings_inline_button.dart';

class ChatAudienceDialog extends StatelessWidget {
  const ChatAudienceDialog({
    super.key,
    required this.controller,
    required this.driveName,
  });
  final ChatController controller;
  final String driveName;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      controller.conversation == null
          ? 'Everyone in $driveName'
          : controller.conversation!.members.length == 2
          ? 'Direct conversation'
          : 'Group conversation',
    ),
    content: SizedBox(
      width: 300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final member in controller.conversation?.members ?? [])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  member.username,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            if (controller.conversation == null)
              const Text(
                'All current drive members can see these messages.',
                style: TextStyle(fontSize: 13),
              ),
          ],
        ),
      ),
    ),
    actions: [
      SettingsInlineButton(
        label: 'Done',
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}
