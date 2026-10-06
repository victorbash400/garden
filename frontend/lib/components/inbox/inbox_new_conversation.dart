import 'package:flutter/material.dart';

import '../../state/inbox_controller.dart';
import '../chat/new_chat_dialog.dart';

class InboxNewConversation {
  static Future<void> open(BuildContext context, InboxController inbox) async {
    final drives = inbox.entries
        .where((entry) => entry.conversationId == null)
        .toList();
    if (drives.isEmpty) return;
    var entry = inbox.selected;
    entry ??= drives.length == 1
        ? drives.first
        : await showDialog(
            context: context,
            builder: (_) => SimpleDialog(
              title: const Text('Choose drive'),
              children: [
                for (final drive in drives)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, drive),
                    child: Text(drive.driveName),
                  ),
              ],
            ),
          );
    if (entry == null || !context.mounted) return;
    await inbox.select(entry);
    if (!context.mounted || inbox.chat == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => NewChatDialog(chat: inbox.chat!),
    );
    await inbox.refresh();
  }
}
