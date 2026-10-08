import 'package:flutter/material.dart';

import 'account_artwork.dart';

class AccountBackground extends StatelessWidget {
  const AccountBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      const AccountArtwork(),
      const ColoredBox(color: Color(0x330B1006)),
      Padding(padding: const EdgeInsets.only(bottom: 64), child: child),
    ],
  );
}
