import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';
import '../services/files/file_type.dart';
import 'system_icon.dart';

class FileIcon extends StatelessWidget {
  const FileIcon({super.key, this.size = 24, this.color, this.name});
  final double size;
  final Color? color;
  final String? name;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return SystemIcon(
      switch (fileType(name ?? '')) {
        FileType.image => SystemIcons.picture,
        FileType.video => SystemIcons.film,
        FileType.audio => SystemIcons.audio,
        FileType.document => SystemIcons.textDocument,
        FileType.code => SystemIcons.code,
        FileType.archive => SystemIcons.archive,
        FileType.other => SystemIcons.file,
      },
      size: size,
      color: color == null || color == colors.ink ? colors.mix(.68) : color,
    );
  }
}
