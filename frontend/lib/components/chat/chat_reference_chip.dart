import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../ui/garden_colors.dart';
import '../file_icon.dart';
import '../folder_icon.dart';
import '../files/toolbar_button.dart';
import '../system_icon.dart';

class ChatReferenceChip extends StatelessWidget {
  const ChatReferenceChip({
    super.key,
    required this.node,
    required this.onRemove,
  });
  final FileNode node;
  final VoidCallback? onRemove;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10, right: 2),
      decoration: BoxDecoration(
        color: GardenColors.of(context).hover,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          node.kind == NodeKind.folder
              ? const FolderIcon(size: 18)
              : FileIcon(size: 18, name: node.name),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              node.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ToolbarButton(
            tooltip: 'Remove mention',
            icon: SystemIcons.x,
            onPressed: onRemove,
          ),
        ],
      ),
    ),
  );
}
