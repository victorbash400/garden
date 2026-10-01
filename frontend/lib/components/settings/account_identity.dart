import 'package:flutter/material.dart';

import '../../ui/garden_theme.dart';

class AccountIdentity extends StatelessWidget {
  const AccountIdentity({super.key, required this.email});
  final String email;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 28),
    child: Column(
      children: [
        CircleAvatar(
          radius: 42,
          backgroundColor: const Color(0xFFE1E5ED),
          child: Text(
            email.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontSize: 30, color: GardenTheme.ink),
          ),
        ),
        const SizedBox(height: 14),
        SelectableText(email, style: const TextStyle(fontSize: 15)),
      ],
    ),
  );
}
