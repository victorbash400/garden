import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: const Color(0xFF555550)),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}
