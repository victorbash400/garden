import 'package:flutter/material.dart';

class AccountBackground extends StatelessWidget {
  const AccountBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      RepaintBoundary(
        child: Image.asset(
          'assets/auth-background.webp',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          excludeFromSemantics: true,
        ),
      ),
      child,
    ],
  );
}
