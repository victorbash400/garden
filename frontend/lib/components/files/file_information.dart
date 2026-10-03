import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import 'file_size.dart';
import 'node_icon.dart';

class FileInformation extends StatelessWidget {
  const FileInformation({super.key, required this.node});
  final FileNode node;
  @override
  Widget build(BuildContext context) {
    final date = node.updatedAt.toLocal();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: NodeIcon(node: node, size: 72),
            ),
          ),
          SelectableText(
            node.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            fileSize(node.size),
            style: const TextStyle(fontSize: 12, color: Color(0xFF777773)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Modified',
                style: TextStyle(fontSize: 11, color: Color(0xFF777773)),
              ),
              const Spacer(),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
