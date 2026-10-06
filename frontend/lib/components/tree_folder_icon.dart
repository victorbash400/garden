import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import 'folder_icon.dart';

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
          SystemIcon(
            SystemIcons.hardDrive,
            size: 20,
            color: GardenColors.of(context).ink,
          )
        else
          FolderIcon(open: open),
        if (connected)
          Positioned(
            right: 0,
            bottom: 0,
            child: Tooltip(
              message: 'Connected drive',
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: GardenColors.of(context).panel,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(1),
                  child: SystemIcon(
                    SystemIcons.link,
                    size: 9,
                    color: GardenColors.of(context).accent,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
