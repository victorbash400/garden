import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../services/files/text_file_type.dart';

List<PopupMenuEntry<String>> nodeMenuItems(
  FileNode node, {
  bool canWrite = true,
}) => [
  const PopupMenuItem(height: 32, value: 'open', child: Text('Open')),
  if (node.kind == NodeKind.file) ...[
    if (canWrite && isTextFile(node.name))
      const PopupMenuItem(height: 32, value: 'edit', child: Text('Edit text')),
    const PopupMenuItem(height: 32, value: 'export', child: Text('Export…')),
  ],
  if (canWrite) ...[
    const PopupMenuItem(height: 32, value: 'rename', child: Text('Rename…')),
    const PopupMenuItem(height: 32, value: 'move', child: Text('Move…')),
    const PopupMenuItem(height: 32, value: 'delete', child: Text('Delete…')),
  ],
];
