import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../system_icon.dart';

class SettingsIconButton extends StatelessWidget {
  const SettingsIconButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final SystemIcons icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      fixedSize: const Size(32, 32),
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: NoSplash.splashFactory,
      foregroundColor: GardenColors.of(context).ink,
      disabledForegroundColor: GardenColors.of(context).disabled,
      hoverColor: GardenColors.of(context).hover,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    icon: SystemIcon(icon, size: 14),
  );
}
