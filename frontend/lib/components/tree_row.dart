import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import 'tree_folder_icon.dart';
import 'file_icon.dart';
import 'list_row.dart';

class TreeRow extends StatelessWidget {
  const TreeRow({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onOpen,
    this.onToggle,
    this.expanded = false,
    this.folderOpen,
    this.depth = 0,
    this.connected = false,
    this.actions,
  });
  final Widget? actions;
  final String label;
  final SystemIcons icon;
  final bool selected;
  final bool expanded;
  final bool? folderOpen;
  final bool connected;
  final int depth;
  final VoidCallback? onOpen;
  final VoidCallback? onToggle;
  static final buttonStyle = TextButton.styleFrom(
    minimumSize: Size.zero,
    padding: EdgeInsets.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    overlayColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: depth * 20, top: 1),
    child: ListRow(
      selected: selected,
      onTap: onOpen,
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 34,
              child: onToggle == null
                  ? null
                  : Semantics(
                      label: '${expanded ? 'Collapse' : 'Expand'} $label',
                      expanded: expanded,
                      child: TextButton(
                        style: buttonStyle,
                        onPressed: onToggle,
                        child: AnimatedRotation(
                          turns: expanded ? 0.25 : 0,
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : Duration(milliseconds: 220),
                          child: SystemIcon(
                            SystemIcons.chevronRight,
                            size: 14,
                            color: GardenColors.of(context).ink,
                          ),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: TextButton(
                onPressed: onOpen,
                style: buttonStyle,
                child: Padding(
                  padding: EdgeInsets.only(left: 2, right: 8),
                  child: Row(
                    children: [
                      icon == SystemIcons.folder ||
                              icon == SystemIcons.hardDrive
                          ? TreeFolderIcon(
                              connected: connected,
                              open: folderOpen ?? (expanded || selected),
                              drive: icon == SystemIcons.hardDrive,
                            )
                          : SizedBox(
                              width: 24,
                              child: icon == SystemIcons.file
                                  ? FileIcon(
                                      size: 24,
                                      color: GardenColors.of(context).ink,
                                    )
                                  : SystemIcon(
                                      icon,
                                      size: 16,
                                      color: GardenColors.of(context).ink,
                                    ),
                            ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: GardenColors.of(context).ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ?actions,
          ],
        ),
      ),
    ),
  );
}
