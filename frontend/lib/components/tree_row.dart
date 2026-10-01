import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'tree_folder_icon.dart';

class TreeRow extends StatelessWidget {
  const TreeRow({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onOpen,
    this.onToggle,
    this.expanded = false,
    this.depth = 0,
    this.connected = false,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final bool expanded;
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
    child: Material(
      color: selected ? const Color(0xFFE8E8E8) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
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
                              : const Duration(milliseconds: 220),
                          child: const Icon(
                            LucideIcons.chevronRight,
                            size: 13,
                            color: Color(0xFF858581),
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
                  padding: const EdgeInsets.only(left: 2, right: 8),
                  child: Row(
                    children: [
                      icon == LucideIcons.folder
                          ? TreeFolderIcon(connected: connected)
                          : SizedBox(
                              width: 24,
                              child: Icon(
                                icon,
                                size: 16,
                                color: const Color(0xFF5C8FC4),
                              ),
                            ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? const Color(0xFF8839EF)
                                : const Color(0xFF333330),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
