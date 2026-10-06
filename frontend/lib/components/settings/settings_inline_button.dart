import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class SettingsInlineButton extends StatelessWidget {
  const SettingsInlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });
  final bool primary;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: Size(0, 32),
      padding: EdgeInsets.symmetric(horizontal: 12),
      backgroundColor: primary
          ? GardenColors.of(context).accent
          : Colors.transparent,
      foregroundColor: primary
          ? GardenColors.of(context).onAccent
          : GardenColors.of(context).ink,
      disabledBackgroundColor: Colors.transparent,
      shape: StadiumBorder(
        side: primary
            ? BorderSide.none
            : BorderSide(color: GardenColors.of(context).border),
      ),
      splashFactory: NoSplash.splashFactory,
      overlayColor: GardenColors.of(context).ink.withValues(alpha: .04),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: Theme.of(context).textTheme.labelLarge!
          .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    ),
    child: Text(label),
  );
}
