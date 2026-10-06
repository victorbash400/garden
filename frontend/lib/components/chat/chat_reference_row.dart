import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../file_icon.dart';
import '../folder_icon.dart';
import '../list_row.dart';
import '../system_icon.dart';

class ChatReferenceRow extends StatelessWidget {
  const ChatReferenceRow({
    super.key,
    required this.node,
    required this.onPressed,
  });
  final FileNode node;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => ListRow(
    onTap: onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Row(
        children: [
          node.kind == NodeKind.folder
              ? const FolderIcon(size: 20)
              : const FileIcon(size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (node.kind == NodeKind.folder)
            const SystemIcon(SystemIcons.chevronRight, size: 14),
        ],
      ),
    ),
  );
}
