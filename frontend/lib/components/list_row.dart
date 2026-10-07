import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

class ListRow extends StatefulWidget {
  const ListRow({
    super.key,
    required this.child,
    required this.onTap,
    this.selected = false,
    this.striped = false,
    this.onDoubleTap,
  });
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool selected;
  final bool striped;
  @override
  State<ListRow> createState() => _ListRowState();
}

class _ListRowState extends State<ListRow> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true),
    onExit: (_) => setState(() => hovered = false),
    child: Semantics(
      button: true,
      selected: widget.selected,
      onTap: widget.onDoubleTap == null ? null : widget.onTap,
      child: Material(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 120),
        color: widget.selected
            ? GardenColors.of(context).selection
            : hovered && widget.onTap != null
            ? GardenColors.of(context).hover
            : widget.striped
            ? GardenColors.of(context).stripe
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onDoubleTap == null ? widget.onTap : null,
          onTapDown: widget.onDoubleTap == null
              ? null
              : (_) => widget.onTap?.call(),
          onDoubleTap: widget.onDoubleTap,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    ),
  );
}
