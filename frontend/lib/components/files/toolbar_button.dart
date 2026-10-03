import 'package:flutter/material.dart';

class ToolbarButton extends StatelessWidget {
  const ToolbarButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });
  final bool selected;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  static final style = IconButton.styleFrom(
    fixedSize: const Size(32, 32),
    minimumSize: Size.zero,
    padding: EdgeInsets.zero,
    foregroundColor: const Color(0xFF4E4E4A),
    disabledForegroundColor: const Color(0xFFC2C2BD),
    hoverColor: const Color(0xFFE4E4E1),
    shape: const RoundedRectangleBorder(),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: selected
        ? style.copyWith(
            backgroundColor: const WidgetStatePropertyAll(Color(0xFFE6E6E3)),
          )
        : style,
    icon: Icon(icon, size: 15),
  );
}
