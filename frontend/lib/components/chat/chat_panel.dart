import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/chat_controller.dart';
import '../../ui/garden_colors.dart';
import '../error_notice.dart';
import 'chat_header.dart';
import 'chat_history.dart';
import 'chat_message_list.dart';
import 'chat_composer.dart';
import 'new_chat_dialog.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({
    super.key,
    required this.controller,
    required this.driveName,
    required this.onFile,
    required this.onMention,
  });
  final ChatController controller;
  final String driveName;
  final ValueChanged<int> onFile;
  final Future<FileNode?> Function() onMention;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(8, 8, 12, 12),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      border: Border.all(color: GardenColors.of(context).border),
      borderRadius: BorderRadius.circular(14),
      color: GardenColors.of(context).panel,
    ),
    child: Column(
      children: [
        ChatHeader(controller: controller, driveName: driveName),
        if (controller.error != null)
          ErrorNotice(
            message: controller.error!,
            action: 'Reconnect',
            onAction: controller.start,
          ),
        if (controller.loading || controller.threadLoading)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: ChatMessageList(
                        controller: controller,
                        onFile: onFile,
                      ),
                    ),
                    ChatComposer(
                      key: ValueKey((
                        controller.thread?.id,
                        controller.conversation?.conversation.id,
                      )),
                      controller: controller,
                      audience: controller.audience(driveName),
                      onMention: onMention,
                    ),
                  ],
                ),
              ),
              if (controller.historyVisible)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: controller.showHistory,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
              if (controller.historyVisible)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: ChatHistory(
                    controller: controller,
                    driveName: driveName,
                    onNew: () => showDialog(
                      context: context,
                      builder: (_) => NewChatDialog(chat: controller),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
