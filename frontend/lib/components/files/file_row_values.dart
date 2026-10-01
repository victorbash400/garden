import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import 'file_size.dart';

class FileRowValues extends StatelessWidget {
  const FileRowValues({super.key, required this.node, required this.width});
  final FileNode node;
  final double width;
  @override
  Widget build(BuildContext context) {
    final date = node.updatedAt.toLocal();
    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 12, color: Color(0xFF777773)),
      child: Row(
        children: [
          if (width >= 480)
            SizedBox(
              width: 140,
              child: Text('${date.day}/${date.month}/${date.year}'),
            ),
          SizedBox(
            width: 80,
            child: Text(
              node.kind == NodeKind.folder ? '—' : fileSize(node.size),
              textAlign: TextAlign.right,
            ),
          ),
          if (width >= 360)
            SizedBox(
              width: 90,
              child: Text(
                node.kind == NodeKind.folder ? 'Folder' : 'File',
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }
}
