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
    this.showHistory = true,
    this.embedded = false,
  });
  final bool showHistory, embedded;
  final ChatController controller;
  final String driveName;
  final ValueChanged<int> onFile;
  final Future<FileNode?> Function() onMention;

  @override
  Widget build(BuildContext context) => Container(
    margin: embedded
        ? EdgeInsets.zero
        : const EdgeInsets.fromLTRB(8, 8, 12, 12),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: embedded ? null : BorderRadius.circular(14),
      color: GardenColors.of(context).panel,
    ),
    foregroundDecoration: embedded
        ? null
        : BoxDecoration(
            border: Border.all(color: GardenColors.of(context).border),
            borderRadius: BorderRadius.circular(14),
          ),
    child: Column(
      children: [
        ChatHeader(
          controller: controller,
          driveName: driveName,
          showHistory: showHistory,
        ),
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
              if (showHistory)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: AnimatedSwitcher(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) => SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            ),
                          ),
                      child: child,
                    ),
                    child: controller.historyVisible
                        ? ChatHistory(
                            controller: controller,
                            driveName: driveName,
                            onNew: () => showDialog(
                              context: context,
                              builder: (_) => NewChatDialog(chat: controller),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
