import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import '../services/chat_gateway.dart';

import 'package:garden_client/garden_client.dart';

import '../components/inbox/inbox_toolbar.dart';
import '../components/inbox/inbox_workspace.dart';
import '../components/inbox/inbox_new_conversation.dart';
import '../components/chat/chat_panel.dart';
import '../components/chat/chat_reference_picker.dart';
import '../components/error_notice.dart';
import 'notifications_settings.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key, required this.controller});
  final GardenController controller;
  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  bool invites = false, drawer = true;
  @override
  Widget build(BuildContext context) {
    final inbox = widget.controller.inbox!;
    return ListenableBuilder(
      listenable: inbox,
      builder: (_, _) => Column(
        children: [
          InboxToolbar(
            invites: invites,
            invitesUnread:
                widget.controller.notifications?.items
                    .where(
                      (item) =>
                          item.invitationId != null &&
                          item.readAt == null &&
                          item.trashedAt == null,
                    )
                    .length ??
                0,
            onInvites: () => setState(() => invites = true),
            onInbox: () => setState(() => invites = false),
          ),
          if (inbox.error != null)
            ErrorNotice(
              message: inbox.error!,
              action: 'Reconnect',
              onAction: inbox.start,
            ),
          if (inbox.loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: invites
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: NotificationsSettings(
                      controller: widget.controller,
                      invitationsOnly: true,
                    ),
                  )
                : InboxWorkspace(
                    controller: inbox,
                    expanded: drawer,
                    onDrawer: () => setState(() => drawer = !drawer),
                    onNew: () => InboxNewConversation.open(context, inbox),
                    conversation: inbox.chat == null || !inbox.chat!.visible
                        ? const Center(child: Text('Select a conversation'))
                        : ChatPanel(
                            controller: inbox.chat!,
                            driveName: inbox.selected?.driveName ?? '',
                            showHistory: false,
                            embedded: true,
                            onFile: (id) => openReference(id),
                            onMention: () => showDialog(
                              context: context,
                              builder: (_) => ChatReferencePicker(
                                gateway: widget.controller.files!.gateway,
                                driveId: inbox.chat!.driveId,
                                driveName: inbox.selected?.driveName ?? '',
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> openReference(int id) async {
    final controller = widget.controller;
    try {
      final client = (controller.gateway as ChatGateway).client;
      final node = await client.files.get(id);
      final drive = controller.gardens
          .where((drive) => drive.id == node.gardenId)
          .first;
      final parents = <FileNode>[];
      var parentId = node.parentId;
      final seen = <int>{};
      while (parentId != 0) {
        if (!seen.add(parentId)) throw StateError('Invalid folder path.');
        final parent = await client.files.get(parentId);
        parents.insert(0, parent);
        parentId = parent.parentId;
      }
      if (!mounted) return;
      await controller.openDrive(drive, root: true);
      final files = controller.files!;
      if (files.error != null) return;
      for (final parent in parents) {
        await files.openFolder(parent);
      }
      if (node.kind == NodeKind.folder) {
        await files.openFolder(node);
      } else {
        files.select(node);
      }
    } catch (failure) {
      controller.files?.reportError(failure);
    }
  }
}
