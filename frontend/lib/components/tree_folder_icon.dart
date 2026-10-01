import 'package:flutter/material.dart';

import 'folder_icon.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class TreeFolderIcon extends StatelessWidget {
  const TreeFolderIcon({
    super.key,
    this.connected = false,
    this.drive = false,
    this.open = false,
  });
  final bool connected;
  final bool drive;
  final bool open;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 24,
    height: 22,
    child: Stack(
      alignment: Alignment.center,
      children: [
        if (drive)
          const Icon(LucideIcons.hardDrive, size: 20, color: Color(0xFF737373))
        else
          FolderIcon(open: open),
        if (connected)
          const Positioned(
            right: 0,
            bottom: 0,
            child: Tooltip(
              message: 'Connected drive',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: Icon(
                    LucideIcons.link,
                    size: 9,
                    color: Color(0xFF5C8FC4),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
