import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

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
  final SystemIcons icon;
  final VoidCallback? onPressed;
  static ButtonStyle style(BuildContext context) => IconButton.styleFrom(
    fixedSize: Size(32, 32),
    minimumSize: Size.zero,
    padding: EdgeInsets.zero,
    splashFactory: NoSplash.splashFactory,
    foregroundColor: GardenColors.of(context).ink,
    disabledForegroundColor: GardenColors.of(context).disabled,
    hoverColor: GardenColors.of(context).hover,
    shape:
        IconButtonTheme.of(context).style?.shape?.resolve({}) ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: style(context).copyWith(
      animationDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      backgroundColor: WidgetStatePropertyAll(
        selected ? GardenColors.of(context).selection : Colors.transparent,
      ),
    ),
    icon: AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: SystemIcon(icon, key: ValueKey(icon), size: 18),
    ),
  );
}
