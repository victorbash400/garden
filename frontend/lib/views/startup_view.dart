import 'package:flutter/material.dart';

import '../components/garden_button.dart';
import '../components/garden_mark.dart';

class StartupView extends StatelessWidget {
  const StartupView({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onSignIn,
  });

  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GardenMark(size: 36),
        const SizedBox(height: 24),
        if (error == null)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else ...[
          GardenButton(label: 'Retry', onPressed: onRetry),
          const SizedBox(height: 12),
          GardenButton(label: 'Sign in', secondary: true, onPressed: onSignIn),
        ],
      ],
    ),
  );
}
