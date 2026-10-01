import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/garden_theme.dart';
import 'file_size.dart';

class FileRow extends StatelessWidget {
  const FileRow({
    super.key,
    required this.node,
    required this.selected,
    required this.onSelect,
    required this.onOpen,
    required this.onAction,
    this.striped = false,
  });
  final bool striped;
  final FileNode node;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;
  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? const Color(0xFFE5EEFC)
        : striped
        ? const Color(0xFFF7F7F7)
        : Colors.white,
    child: SizedBox(
      height: 32,
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onSelect,
                onDoubleTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Row(
                    children: [
                      Icon(
                        node.kind == NodeKind.folder
                            ? LucideIcons.folder
                            : LucideIcons.file,
                        size: 19,
                        color: node.kind == NodeKind.folder
                            ? GardenTheme.blue
                            : GardenTheme.secondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          node.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (constraints.maxWidth - 68 >= 480)
                        SizedBox(
                          width: 140,
                          child: Text(
                            '${node.updatedAt.toLocal().day}/${node.updatedAt.toLocal().month}/${node.updatedAt.toLocal().year}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: GardenTheme.secondary,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: 80,
                        child: Text(
                          node.kind == NodeKind.folder
                              ? '—'
                              : fileSize(node.size),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GardenTheme.secondary,
                          ),
                        ),
                      ),
                      if (constraints.maxWidth - 68 >= 360)
                        SizedBox(
                          width: 90,
                          child: Text(
                            node.kind == NodeKind.folder ? 'Folder' : 'File',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 11,
                              color: GardenTheme.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'File actions',
              icon: const Icon(LucideIcons.ellipsis, size: 16),
              onSelected: onAction,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'open',
                  child: Text(
                    node.kind == NodeKind.folder ? 'Open folder' : 'Edit text',
                  ),
                ),
                if (node.kind == NodeKind.file)
                  const PopupMenuItem(value: 'export', child: Text('Export…')),
                const PopupMenuItem(value: 'rename', child: Text('Rename…')),
                const PopupMenuItem(value: 'move', child: Text('Move…')),
                const PopupMenuItem(value: 'delete', child: Text('Delete…')),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
