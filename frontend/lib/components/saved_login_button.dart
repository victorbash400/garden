import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'garden_button.dart';

class SavedLoginButton extends StatelessWidget {
  const SavedLoginButton({
    super.key,
    required this.email,
    required this.onContinue,
    required this.onForget,
  });
  final String email;
  final VoidCallback? onContinue;
  final VoidCallback? onForget;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: GardenButton(
          label: 'Continue as $email',
          secondary: true,
          onPressed: onContinue,
        ),
      ),
      IconButton(
        tooltip: 'Forget saved login',
        onPressed: onForget,
        icon: const Icon(LucideIcons.x, size: 16),
      ),
    ],
  );
}
