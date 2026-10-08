import 'dart:ui';

import 'package:flutter/material.dart';

class SignInFieldSurface extends StatelessWidget {
  const SignInFieldSurface({
    super.key,
    required this.enabled,
    required this.child,
  });
  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) => enabled
      ? ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: child,
          ),
        )
      : child;
}
