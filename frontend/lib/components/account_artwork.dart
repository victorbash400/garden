import 'package:flutter/material.dart';

class AccountArtwork extends StatelessWidget {
  const AccountArtwork({super.key});

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/garden-moss.webp',
    fit: BoxFit.cover,
    alignment: const Alignment(0.25, 0),
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
  );
}
