import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class HoverRename extends StatefulWidget {
  const HoverRename({
    super.key,
    required this.child,
    required this.onRename,
    this.right = 4,
  });
  final Widget child;
  final VoidCallback? onRename;
  final double right;
  @override
  State<HoverRename> createState() => _HoverRenameState();
}

class _HoverRenameState extends State<HoverRename> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: Stack(
      children: [
        widget.child,
        if (hovered && widget.onRename != null)
          Positioned(
            top: 2,
            right: widget.right,
            child: SizedBox(
              width: 27,
              height: 27,
              child: IconButton(
                tooltip: 'Rename',
                onPressed: widget.onRename,
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  backgroundColor: GardenColors.of(context).hover,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                icon: SystemIcon(
                  SystemIcons.squarePen,
                  size: 14,
                  color: GardenColors.of(context).ink,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
