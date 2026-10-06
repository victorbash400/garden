import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import '../../services/files/files_gateway.dart';
import '../../utils/error_message.dart';
import '../error_notice.dart';
import '../files/toolbar_button.dart';
import '../settings/settings_inline_button.dart';
import '../system_icon.dart';
import 'chat_reference_row.dart';

class ChatReferencePicker extends StatefulWidget {
  const ChatReferencePicker({
    super.key,
    this.files,
    this.gateway,
    this.driveId,
    this.driveName,
  });
  final FilesController? files;
  final FilesGateway? gateway;
  final int? driveId;
  final String? driveName;
  @override
  State<ChatReferencePicker> createState() => _ChatReferencePickerState();
}

class _ChatReferencePickerState extends State<ChatReferencePicker> {
  final cache = <int, List<FileNode>>{};
  final path = <FileNode>[];
  List<FileNode> nodes = [];
  bool busy = false;
  String? error;
  int get parent => path.isEmpty ? 0 : path.last.id!;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final id = parent;
      final index = widget.files?.folders;
      final values =
          cache[id] ??
          (index != null && index.isLoaded(id)
              ? index.directory(id)
              : (await (widget.files?.gateway ?? widget.gateway!).list(
                  widget.files?.drive?.id ?? widget.driveId!,
                  id,
                )).nodes);
      if (!mounted) return;
      cache[id] = values;
      setState(() => nodes = values);
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Mention file or folder'),
    content: SizedBox(
      width: 420,
      height: 340,
      child: Column(
        children: [
          Row(
            children: [
              ToolbarButton(
                tooltip: 'Parent folder',
                icon: SystemIcons.arrowLeft,
                onPressed: busy || path.isEmpty
                    ? null
                    : () {
                        path.removeLast();
                        load();
                      },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  path.isEmpty
                      ? (widget.files?.drive?.name ?? widget.driveName!)
                      : path.last.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          if (busy) const LinearProgressIndicator(minHeight: 2),
          if (error != null)
            ErrorNotice(message: error!, action: 'Retry', onAction: load),
          Expanded(
            child: ListView.builder(
              itemCount: busy ? 0 : nodes.length,
              itemBuilder: (_, index) => ChatReferenceRow(
                node: nodes[index],
                onPressed: () {
                  final node = nodes[index];
                  if (node.kind == NodeKind.folder) {
                    path.add(node);
                    load();
                  } else {
                    Navigator.pop(context, node);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ),
    actions: [
      if (path.isNotEmpty)
        SettingsInlineButton(
          label: 'Mention this folder',
          onPressed: () => Navigator.pop(context, path.last),
        ),
      SettingsInlineButton(
        label: 'Cancel',
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}
