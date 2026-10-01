import 'package:flutter/material.dart';

import '../ui/garden_theme.dart';

class GardenButton extends StatelessWidget {
  const GardenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: secondary ? Colors.white : GardenTheme.ink,
        foregroundColor: secondary ? GardenTheme.ink : Colors.white,
        disabledBackgroundColor: GardenTheme.selection,
        disabledForegroundColor: GardenTheme.secondary,
        minimumSize: const Size(108, 42),
        padding: EdgeInsets.symmetric(horizontal: secondary ? 17 : 24),
        shape: StadiumBorder(
          side: secondary
              ? const BorderSide(color: Color(0xFFDADADD))
              : BorderSide.none,
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    ),
  );
}
