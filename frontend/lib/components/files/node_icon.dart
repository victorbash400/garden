import 'package:flutter/material.dart';

import 'package:garden_client/garden_client.dart';

import '../folder_icon.dart';
import '../file_icon.dart';

class NodeIcon extends StatelessWidget {
  const NodeIcon({
    super.key,
    required this.node,
    this.size = 24,
    this.open = false,
  });
  final FileNode node;
  final double size;
  final bool open;
  @override
  Widget build(BuildContext context) => node.kind == NodeKind.folder
      ? FolderIcon(size: size, open: open)
      : FileIcon(size: size);
}
