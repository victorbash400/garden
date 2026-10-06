import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_theme.dart';
import '../ui/garden_colors.dart';

class GardenButton extends StatelessWidget {
  const GardenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.onDark = false,
    this.icon,
    this.backgroundColor,
    this.disabledBackgroundColor,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool onDark;
  final SystemIcons? icon;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: onDark ? 52 : 42,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor:
            backgroundColor ??
            (onDark
                ? secondary
                      ? const Color(0x306C776A)
                      : const Color(0xFFE0E6DA)
                : secondary
                ? GardenColors.of(context).panel
                : GardenColors.of(context).legacy
                ? GardenTheme.ink
                : GardenColors.of(context).accent),
        foregroundColor: onDark
            ? secondary
                  ? const Color(0xFFE3E9DE)
                  : const Color(0xFF293326)
            : secondary
            ? GardenColors.of(context).ink
            : GardenColors.of(context).legacy
            ? Colors.white
            : GardenColors.of(context).onAccent,
        disabledBackgroundColor:
            disabledBackgroundColor ??
            (onDark
                ? const Color(0xB3D9E0D4)
                : GardenColors.of(context).selection),
        disabledForegroundColor: onDark
            ? const Color(0xFF57604F)
            : GardenColors.of(context).secondary,
        minimumSize: Size(108, onDark ? 52 : 42),
        padding: EdgeInsets.symmetric(horizontal: secondary ? 17 : 24),
        shape: StadiumBorder(
          side: secondary
              ? BorderSide(
                  color: onDark
                      ? const Color(0x507F8C78)
                      : GardenColors.of(context).border,
                )
              : BorderSide.none,
        ),
        textStyle: Theme.of(context).textTheme.labelLarge!
            .copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            SystemIcon(icon!, size: 16),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    ),
  );
}
