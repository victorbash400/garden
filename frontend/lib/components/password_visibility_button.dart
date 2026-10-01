import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../ui/garden_theme.dart';

class PasswordVisibilityButton extends StatelessWidget {
  const PasswordVisibilityButton({
    super.key,
    required this.visible,
    this.onPressed,
  });

  final bool visible;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: visible ? 'Hide password' : 'Show password',
    onPressed: onPressed,
    icon: Icon(visible ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
    color: GardenTheme.secondary,
  );
}
