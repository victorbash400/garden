import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../ui/garden_theme.dart';

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.visible,
    this.onPressed,
    this.color = GardenTheme.secondary,
  });

  final bool visible;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: visible ? 'Hide password' : 'Show password',
    onPressed: onPressed,
    icon: SystemIcon(visible ? SystemIcons.eyeOff : SystemIcons.eye, size: 18),
    color: color,
  );
}
