import '../system_icon.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import 'file_size.dart';

class FileVersionsList extends StatelessWidget {
  const FileVersionsList({
    super.key,
    required this.versions,
    required this.userId,
    required this.onExport,
  });
  final List<FileVersion> versions;
  final String userId;
  final ValueChanged<FileVersion> onExport;
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final version in versions)
        ListTile(
          dense: true,
          title: Text(
            version.createdAt.toLocal().toString().split('.').first,
            style: const TextStyle(fontSize: 12),
          ),
          subtitle: Text(
            '${version.authorId == userId ? 'You' : version.authorId} · ${fileSize(version.size)}',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: IconButton(
            tooltip: 'Export this version',
            icon: const SystemIcon(SystemIcons.download, size: 17),
            onPressed: () => onExport(version),
          ),
        ),
    ],
  );
}
