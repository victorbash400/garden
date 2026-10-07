import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/chat_controller.dart';
import '../../ui/garden_colors.dart';
import '../files/toolbar_button.dart';
import '../system_icon.dart';
import 'chat_reference_chip.dart';
import 'chat_send_button.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onMention,
    required this.audience,
  });
  final String audience;
  final ChatController controller;
  final Future<FileNode?> Function() onMention;
  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final input = TextEditingController();
  final focus = FocusNode();
  FileNode? reference;
  bool picking = false;
  bool get enabled =>
      !widget.controller.sending && !widget.controller.threadLoading;
  bool get canSend =>
      enabled && (input.text.trim().isNotEmpty || reference != null);

  @override
  void dispose() {
    input.dispose();
    focus.dispose();
    super.dispose();
  }

  Future<void> mention() async {
    if (picking) return;
    picking = true;
    try {
      final node = await widget.onMention();
      if (!mounted) return;
      if (node != null) {
        if (input.text.endsWith('@')) {
          input.text = input.text.substring(0, input.text.length - 1);
        }
        setState(() => reference = node);
      }
      focus.requestFocus();
    } finally {
      picking = false;
    }
  }

  Future<void> send() async {
    if (!canSend || input.value.composing.isValid) return;
    final text = input.text;
    final node = reference;
    if (await widget.controller.send(text, nodeId: node?.id) && mounted) {
      if (input.text == text) input.clear();
      if (reference == node) setState(() => reference = null);
      focus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (reference != null)
              ChatReferenceChip(
                node: reference!,
                onRemove: enabled
                    ? () => setState(() => reference = null)
                    : null,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ToolbarButton(
                  tooltip: 'Mention file or folder',
                  icon: SystemIcons.link,
                  onPressed: enabled ? mention : null,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter): () =>
                            send(),
                      },
                      child: TextField(
                        onChanged: (text) {
                          if (text.endsWith('@') &&
                              (text.length == 1 ||
                                  text[text.length - 2].trim().isEmpty)) {
                            mention();
                          }
                        },
                        autofocus: true,
                        controller: input,
                        focusNode: focus,
                        enabled: enabled,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 4000,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                        decoration: InputDecoration(
                          hintText: 'Message ${widget.audience}',
                          hintMaxLines: 1,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          filled: false,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ValueListenableBuilder(
                  valueListenable: input,
                  builder: (_, value, _) =>
                      ChatSendButton(onPressed: canSend ? send : null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
