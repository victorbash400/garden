import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: NodeIcon(node: node, size: 72),
            ),
          ),
          SelectableText(
            node.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            fileSize(node.size),
            style: TextStyle(
              fontSize: 12,
              color: GardenColors.of(context).secondary,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Modified',
                style: TextStyle(
                  fontSize: 11,
                  color: GardenColors.of(context).secondary,
                ),
              ),
              Spacer(),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: TextStyle(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
