import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../ui/garden_theme.dart';

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
  });
  final String label;
  final IconData icon;
  final bool selected;
  final bool expanded;
  final int depth;
  final VoidCallback? onOpen;
  final VoidCallback? onToggle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 8 + depth * 12, right: 8, top: 1, bottom: 1),
    child: Material(
      color: selected ? GardenTheme.selection : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 32,
            child: onToggle == null
                ? null
                : IconButton(
                    tooltip: '${expanded ? 'Collapse' : 'Expand'} $label',
                    padding: EdgeInsets.zero,
                    onPressed: onToggle,
                    icon: Icon(
                      expanded
                          ? LucideIcons.chevronDown
                          : LucideIcons.chevronRight,
                      size: 13,
                    ),
                  ),
          ),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
                child: Row(
                  children: [
                    Icon(icon, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
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
  );
}
