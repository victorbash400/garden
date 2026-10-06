import 'package:flutter/material.dart';

import '../../state/chat_controller.dart';
import '../../utils/error_message.dart';
import '../garden_field.dart';
import '../error_notice.dart';
import '../settings/settings_inline_button.dart';

class ConversationActionDialog extends StatefulWidget {
  const ConversationActionDialog({
    super.key,
    required this.chat,
    required this.action,
  });
  final ChatController chat;
  final String action;
  @override
  State<ConversationActionDialog> createState() =>
      _ConversationActionDialogState();
}

class _ConversationActionDialogState extends State<ConversationActionDialog> {
  late final text = TextEditingController(
    text: widget.chat.conversation!.conversation.title,
  );
  bool busy = false;
  String? error;
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final chat = widget.chat;
      final id = chat.conversation!.conversation.id!;
      if (widget.action == 'rename') {
        await chat.service.renameConversation(id, text.text);
        chat.conversation!.conversation.title = text.text.trim();
        chat.notifyAudienceChanged();
      } else {
        if (widget.action == 'delete') {
          await chat.service.deleteConversation(id);
        } else {
          await chat.service.leaveConversation(id);
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.action == 'rename'
          ? 'Rename conversation'
          : widget.action == 'delete'
          ? 'Delete conversation?'
          : 'Leave conversation?',
    ),
    content: SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.action == 'rename')
            GardenField(label: 'Name', controller: text, enabled: !busy),
          if (widget.action == 'delete')
            const Text(
              'Deletes the messages for everyone in this conversation.',
            ),
          if (widget.action == 'leave')
            const Text(
              'You will no longer receive messages in this conversation.',
            ),
          if (error != null) ErrorNotice(message: error!),
        ],
      ),
    ),
    actions: [
      SettingsInlineButton(
        label: 'Cancel',
        onPressed: busy ? null : () => Navigator.pop(context),
      ),
      SettingsInlineButton(
        label: widget.action == 'rename'
            ? 'Save'
            : widget.action == 'delete'
            ? 'Delete'
            : 'Leave',
        primary: true,
        onPressed: busy ? null : submit,
      ),
    ],
  );
}
