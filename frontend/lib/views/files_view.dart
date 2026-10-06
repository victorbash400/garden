import 'dart:async';

import 'package:flutter/material.dart';

import '../services/chat_gateway.dart';
import '../state/chat_controller.dart';
import '../components/chat/chat_panel.dart';
import '../components/chat/share_reference_dialog.dart';
import '../components/chat/chat_reference_picker.dart';

import '../ui/garden_colors.dart';

import 'package:garden_client/garden_client.dart';

import '../components/error_notice.dart';
import '../components/files/directory_browser.dart';
import '../components/files/file_keyboard_bindings.dart';
import '../components/files/file_actions.dart';
import '../components/files/file_details.dart';
import '../components/files/files_toolbar.dart';
import '../state/files_controller.dart';

class FilesView extends StatefulWidget {
  const FilesView({
    super.key,
    required this.controller,
    required this.userId,
    required this.onBackToDrives,
    this.inboxUnread,
    this.onInbox,
    this.onConnections,
    this.onManageDrive,
    this.chatService,
    this.focusEvents,
  });
  final int? inboxUnread;
  final VoidCallback? onInbox;
  final ChatService? chatService;
  final Stream<void>? focusEvents;
  final FilesController controller;
  final String userId;
  final VoidCallback onBackToDrives;
  final VoidCallback? onConnections, onManageDrive;
  @override
  State<FilesView> createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> with WidgetsBindingObserver {
  ChatController? chat;
  StreamSubscription<void>? focus;
  FilesController get controller => widget.controller;
  String get userId => widget.userId;
  VoidCallback get onBackToDrives => widget.onBackToDrives;
  VoidCallback? get onManageDrive => widget.onManageDrive;
  VoidCallback? get onConnections => widget.onConnections;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final service = widget.chatService;
    if (service != null) {
      chat = ChatController(service, controller.drive!.id, userId)
        ..addListener(changed);
      controller.shareNode = shareNode;
      if (widget.onInbox == null) {
        unawaited(chat!.start());
      }
      focus = widget.focusEvents?.listen((_) => reconnect());
      if (service is ServerpodChatService) {
        service.client.connectivityMonitor?.addListener(connectivityChanged);
      }
    }
  }

  void connectivityChanged(bool connected) {
    if (connected) reconnect();
  }

  void changed() {
    if (mounted) setState(() {});
  }

  void reconnect() {
    if ((widget.onInbox == null || chat?.visible == true) &&
        chat != null &&
        !chat!.connected &&
        !chat!.loading) {
      unawaited(chat!.start());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) reconnect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(focus?.cancel());
    final service = widget.chatService;
    if (service is ServerpodChatService) {
      service.client.connectivityMonitor?.removeListener(connectivityChanged);
    }
    controller.shareNode = null;
    chat?.dispose();
    super.dispose();
  }

  Future<void> shareNode(FileNode node) async {
    controller.select(node);
    await share();
  }

  Future<void> share() async {
    final node = controller.selected;
    if (node == null || chat == null) return;
    if (!chat!.connected && !chat!.loading) {
      await chat!.start();
    }
    if (!mounted) return;
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => ShareReferenceDialog(
        chat: chat!,
        node: node,
        driveName: controller.drive!.name,
      ),
    );
    if (sent == true && mounted) {
      if (widget.onInbox != null) {
        widget.onInbox!();
      } else if (!chat!.visible) {
        chat!.toggle();
      }
    }
  }

  Future<void> openReference(int id) async {
    try {
      final service = widget.chatService;
      if (service is! ServerpodChatService) {
        throw StateError('File navigation is unavailable.');
      }
      final node = await service.client.files.get(id);
      if (!mounted || node.gardenId != controller.drive!.id) return;
      final parents = <FileNode>[];
      var parentId = node.parentId;
      final seen = <int>{};
      while (parentId != 0) {
        if (!seen.add(parentId)) throw StateError('Invalid folder path.');
        final parent = await service.client.files.get(parentId);
        parents.insert(0, parent);
        parentId = parent.parentId;
      }
      if (!mounted) return;
      await controller.goTo(0);
      if (chat?.visible == true) chat!.toggle();
      for (final parent in parents) {
        if (!mounted) return;
        await controller.openFolder(parent);
      }
      if (!mounted) return;
      if (node.kind == NodeKind.folder) {
        await controller.openFolder(node);
      } else {
        controller.select(node);
      }
    } catch (failure) {
      if (mounted) controller.reportError(failure);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final actions = FileActions(context, controller);
      final selected = controller.selected;
      return FileKeyboardBindings(
        controller: controller,
        child: ColoredBox(
          color: GardenColors.of(context).panel,
          child: Column(
            children: [
              FilesToolbar(
                controller: controller,
                onImport: actions.import,
                onInvite: onManageDrive,
                onBackToDrives: onBackToDrives,
                onConnections: onConnections,
                onChat: widget.onInbox ?? chat?.toggle,
                onShare: chat == null ? null : share,
                chatUnread: widget.inboxUnread ?? chat?.unread ?? 0,
                chatVisible: chat?.visible ?? false,
              ),
              SizedBox(
                height: 2,
                child: controller.busy
                    ? LinearProgressIndicator(
                        minHeight: 2,
                        value: controller.progress,
                      )
                    : null,
              ),
              if (controller.error != null)
                ErrorNotice(
                  message: controller.error!,
                  onDismiss: controller.dismissError,
                ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: DirectoryBrowser(controller: controller)),
                    if (chat?.visible != true &&
                        selected != null &&
                        selected.kind == NodeKind.file)
                      FileDetails(
                        key: ValueKey(selected.id),
                        gateway: controller.gateway,
                        node: selected,
                        revision: controller.detailsRevision,
                        userId: userId,
                        identities: chat?.identities ?? const {},
                        canWrite: controller.canWrite,
                        onExport: (version) =>
                            actions.export(selected, version: version),
                      ),
                    if (chat?.visible == true)
                      SizedBox(
                        width: 420,
                        child: ChatPanel(
                          controller: chat!,
                          driveName: controller.drive!.name,
                          onFile: openReference,
                          onMention: () => showDialog<FileNode>(
                            context: context,
                            builder: (_) =>
                                ChatReferencePicker(files: controller),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: GardenColors.of(context).border),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                child: Row(
                  children: [
                    Text(
                      '${controller.nodes.length} ${controller.nodes.length == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        fontSize: 11,
                        color: GardenColors.of(context).secondary,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
