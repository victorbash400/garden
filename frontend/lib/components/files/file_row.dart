import 'hover_rename.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/garden_theme.dart';
import '../list_row.dart';
import '../folder_icon.dart';
import 'file_row_values.dart';
import 'node_menu_items.dart';

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
  Widget build(BuildContext context) => HoverRename(
    onRename: () => onAction('rename'),
    right: 48,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: .5),
      child: ListRow(
        selected: selected,
        striped: striped,
        onTap: onSelect,
        onDoubleTap: onOpen,
        child: SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              children: [
                const SizedBox(width: 9),
                if (node.kind == NodeKind.folder)
                  FolderIcon(size: 24, open: selected)
                else
                  const Icon(
                    LucideIcons.file,
                    size: 17,
                    color: GardenTheme.secondary,
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
                  itemBuilder: (_) => nodeMenuItems(node),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
