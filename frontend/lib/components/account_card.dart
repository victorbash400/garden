import 'package:flutter/material.dart';

import 'account_brand.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xEFF7F7F2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [const AccountBrand(), const SizedBox(height: 32), child],
      ),
    ),
  );
}
