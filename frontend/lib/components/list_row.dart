import 'package:flutter/material.dart';

class ListRow extends StatefulWidget {
  const ListRow({
    super.key,
    required this.child,
    required this.onTap,
    this.selected = false,
    this.striped = false,
  });
  final Widget child;
  final VoidCallback? onTap;
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
    child: Material(
      color: widget.selected
          ? const Color(0xFFE8E8E8)
          : hovered
          ? const Color(0xFFEDEDEB)
          : widget.striped
          ? const Color(0xFFF7F7F6)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(7),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: widget.child,
      ),
    ),
  );
}
