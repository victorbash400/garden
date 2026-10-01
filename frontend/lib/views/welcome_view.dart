import 'package:flutter/material.dart';

import '../components/app_tile.dart';
import '../components/garden_button.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({
    super.key,
    required this.onSignIn,
    required this.onRegister,
  });
  final VoidCallback onSignIn;
  final VoidCallback onRegister;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppTile(),
        const SizedBox(height: 32),
        GardenButton(label: 'Sign in', onPressed: onSignIn),
        const SizedBox(height: 12),
        GardenButton(
          label: 'Create account',
          secondary: true,
          onPressed: onRegister,
        ),
      ],
    ),
  );
}
