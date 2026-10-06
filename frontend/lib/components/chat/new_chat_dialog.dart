import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/chat_controller.dart';
import '../../utils/error_message.dart';
import '../error_notice.dart';
import '../garden_field.dart';
import '../settings/settings_inline_button.dart';
import 'chat_recipient_row.dart';

class NewChatDialog extends StatefulWidget {
  const NewChatDialog({super.key, required this.chat});
  final ChatController chat;
  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final selected = <String>{};
  final title = TextEditingController();
  List<PublicIdentity> members = [];
  bool loading = true, saving = false;
  String? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final values = await widget.chat.service.members(widget.chat.driveId);
      if (mounted) {
        setState(
          () => members =
              values
                  .where((value) => value.userId != widget.chat.userId)
                  .toList()
                ..sort((a, b) => a.username.compareTo(b.username)),
        );
      }
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> create() async {
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await widget.chat.createConversation(selected.toList(), title.text);
      if (mounted) Navigator.pop(context);
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('New conversation'),
    content: SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GardenField(
            label: 'Name (optional)',
            controller: title,
            enabled: !saving,
          ),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          if (error != null)
            ErrorNotice(
              message: error!,
              action: loading ? null : 'Retry',
              onAction: load,
            ),
          if (!loading && error == null && members.isEmpty)
            const Text(
              'Invite someone to this drive to start a conversation.',
              style: TextStyle(fontSize: 13),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final member in members)
                  ChatRecipientRow(
                    member: member,
                    selected: selected.contains(member.userId),
                    onChanged: saving
                        ? null
                        : () => setState(() {
                            if (!selected.add(member.userId)) {
                              selected.remove(member.userId);
                            }
                          }),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    actions: [
      SettingsInlineButton(
        label: 'Cancel',
        onPressed: saving ? null : () => Navigator.pop(context),
      ),
      SettingsInlineButton(
        label: saving ? 'Opening…' : 'Open conversation',
        primary: true,
        onPressed: saving || loading || selected.isEmpty ? null : create,
      ),
    ],
  );
}
