import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../utils/error_message.dart';

import '../../services/files/files_gateway.dart';

class FileMoveDialog extends StatefulWidget {
  const FileMoveDialog({super.key, required this.gateway, required this.node});
  final FilesGateway gateway;
  final FileNode node;
  @override
  State<FileMoveDialog> createState() => _FileMoveDialogState();
}

class _FileMoveDialogState extends State<FileMoveDialog> {
  List<FileNode> path = [];
  List<FileNode> folders = [];
  bool busy = true;
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
      final listing = await widget.gateway.list(widget.node.gardenId, parent);
      if (mounted) {
        setState(
          () => folders = listing.nodes
              .where(
                (node) =>
                    node.kind == NodeKind.folder && node.id != widget.node.id,
              )
              .toList(),
        );
      }
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: SizedBox(
      width: 360,
      height: 300,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Parent folder',
                onPressed: busy || path.isEmpty
                    ? null
                    : () {
                        path.removeLast();
                        load();
                      },
                icon: const Icon(LucideIcons.chevronLeft, size: 18),
              ),
              Expanded(
                child: Text(
                  path.isEmpty ? 'Drive' : path.last.name,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          if (busy) const LinearProgressIndicator(minHeight: 2),
          if (error != null)
            SelectableText(
              error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          Expanded(
            child: ListView(
              children: [
                for (final folder in folders)
                  ListTile(
                    dense: true,
                    leading: const Icon(LucideIcons.folder, size: 18),
                    title: Text(folder.name),
                    onTap: busy
                        ? null
                        : () {
                            path.add(folder);
                            load();
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: busy || error != null
            ? null
            : () => Navigator.pop(context, parent),
        child: const Text('Move here'),
      ),
    ],
  );
}
