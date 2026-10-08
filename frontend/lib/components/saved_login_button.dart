import 'system_icon.dart';

import 'package:flutter/material.dart';

import 'garden_button.dart';

class SavedLoginButton extends StatelessWidget {
  const SavedLoginButton({
    super.key,
    this.onDark = false,
    required this.email,
    this.touchId = false,
    required this.onContinue,
    required this.onForget,
  });
  final bool touchId;
  final String email;
  final VoidCallback? onContinue;
  final VoidCallback? onForget;
  final bool onDark;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GardenButton(
          label: touchId ? 'Use Touch ID · $email' : 'Continue as $email',
          secondary: true,
          onDark: onDark,
          onPressed: onContinue,
        ),
      ),
      IconButton(
        tooltip: 'Forget saved login',
        onPressed: onForget,
        icon: const SystemIcon(SystemIcons.x, size: 16),
      ),
    ],
  );
}
