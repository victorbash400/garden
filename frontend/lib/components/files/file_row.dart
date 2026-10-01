import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/garden_theme.dart';
import '../list_row.dart';
import 'file_row_values.dart';

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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: .5),
    child: ListRow(
      selected: selected,
      striped: striped,
      onTap: node.kind == NodeKind.folder ? onOpen : onSelect,
      child: SizedBox(
        height: 32,
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              const SizedBox(width: 9),
              Icon(
                node.kind == NodeKind.folder
                    ? LucideIcons.folder
                    : LucideIcons.file,
                size: 17,
                color: node.kind == NodeKind.folder
                    ? GardenTheme.blue
                    : GardenTheme.secondary,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              FileRowValues(node: node, width: constraints.maxWidth - 57),
              PopupMenuButton<String>(
                tooltip: 'File actions',
                padding: EdgeInsets.zero,
                icon: const Icon(LucideIcons.ellipsis, size: 16),
                onSelected: onAction,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'open',
                    child: Text(
                      node.kind == NodeKind.folder
                          ? 'Open folder'
                          : 'Edit text',
                    ),
                  ),
                  if (node.kind == NodeKind.file)
                    const PopupMenuItem(
                      value: 'export',
                      child: Text('Export…'),
                    ),
                  const PopupMenuItem(value: 'rename', child: Text('Rename…')),
                  const PopupMenuItem(value: 'move', child: Text('Move…')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete…')),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
