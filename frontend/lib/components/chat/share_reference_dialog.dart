import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/chat_controller.dart';
import '../garden_field.dart';
import '../error_notice.dart';
import '../settings/settings_inline_button.dart';

class ShareReferenceDialog extends StatefulWidget {
  const ShareReferenceDialog({
    super.key,
    required this.chat,
    required this.node,
    required this.driveName,
  });
  final ChatController chat;
  final FileNode node;
  final String driveName;
  @override
  State<ShareReferenceDialog> createState() => _ShareReferenceDialogState();
}

class _ShareReferenceDialogState extends State<ShareReferenceDialog> {
  final message = TextEditingController();
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.chat,
    builder: (context, _) => AlertDialog(
      title: Text('Share ${widget.node.name}'),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.chat.audience(widget.driveName),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            GardenField(
              label: 'Message (optional)',
              controller: message,
              enabled: !widget.chat.sending,
            ),
            if (widget.chat.error != null)
              ErrorNotice(message: widget.chat.error!),
          ],
        ),
      ),
      actions: [
        SettingsInlineButton(
          label: 'Cancel',
          onPressed: widget.chat.sending ? null : () => Navigator.pop(context),
        ),
        SettingsInlineButton(
          label: widget.chat.sending ? 'Sharing…' : 'Share',
          primary: true,
          onPressed: widget.chat.sending
              ? null
              : () async {
                  widget.chat.openThread(null);
                  if (await widget.chat.send(
                        message.text,
                        nodeId: widget.node.id,
                      ) &&
                      context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
        ),
      ],
    ),
  );
}
