import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xF5FFFFFF),
      border: Border.all(color: const Color(0xFFD8DDD2)),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(padding: const EdgeInsets.all(24), child: child),
  );
}
