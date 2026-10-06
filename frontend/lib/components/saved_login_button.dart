import 'system_icon.dart';
import 'package:flutter/material.dart';

import 'garden_button.dart';

class SavedLoginButton extends StatelessWidget {
  const SavedLoginButton({
    super.key,
    required this.email,
    this.touchId = false,
    required this.onContinue,
    required this.onForget,
  });
  final bool touchId;
  final String email;
  final VoidCallback? onContinue;
  final VoidCallback? onForget;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GardenButton(
          label: touchId ? 'Use Touch ID · $email' : 'Continue as $email',
          secondary: true,
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
