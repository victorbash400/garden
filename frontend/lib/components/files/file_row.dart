import '../system_icon.dart';
import 'hover_rename.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../list_row.dart';
import 'node_icon.dart';
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
    this.canWrite = true,
  });
  final bool striped, canWrite;
  final FileNode node;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onOpen;
  final ValueChanged<String> onAction;
  @override
  Widget build(BuildContext context) => HoverRename(
    onRename: canWrite ? () => onAction('rename') : null,
    right: 48,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: .5),
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
                SizedBox(width: 9),
                NodeIcon(node: node, size: 24, open: selected),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    node.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                FileRowValues(node: node, width: constraints.maxWidth - 57),
                PopupMenuButton<String>(
                  tooltip: 'File actions',
                  padding: EdgeInsets.zero,
                  icon: SystemIcon(SystemIcons.ellipsis, size: 16),
                  onSelected: onAction,
                  itemBuilder: (_) => nodeMenuItems(node, canWrite: canWrite),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
