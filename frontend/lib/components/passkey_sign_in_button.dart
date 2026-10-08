import 'package:flutter/material.dart';

import '../state/account_security_controller.dart';
import 'garden_button.dart';

class PasskeySignInButton extends StatelessWidget {
  const PasskeySignInButton({
    super.key,
    this.onDark = false,
    required this.security,
    required this.busy,
    required this.onPressed,
  });
  final AccountSecurityController security;
  final bool busy;
  final VoidCallback onPressed;
  final bool onDark;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: security,
    builder: (context, _) => Tooltip(
      message: security.configured
          ? 'Sign in with a saved passkey'
          : 'Apple signing setup required',
      child: GardenButton(
        label: 'Sign in with passkey',
        secondary: !onDark,
        onDark: onDark,
        disabledBackgroundColor: onDark ? const Color(0xFFE0E6DA) : null,
        onPressed: security.configured && !busy ? onPressed : null,
      ),
    ),
  );
}
