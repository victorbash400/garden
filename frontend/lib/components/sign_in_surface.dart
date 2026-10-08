import 'package:flutter/material.dart';

import 'account_brand.dart';

class SignInSurface extends StatelessWidget {
  const SignInSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: const Color(0xFFE7ECE1),
        onSurface: const Color(0xFFE7ECE1),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: const Color(0xFFDCE2D5)),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccountBrand(color: Color(0xFFE7ECE1)),
          const SizedBox(height: 32),
          child,
        ],
      ),
    ),
  );
}
