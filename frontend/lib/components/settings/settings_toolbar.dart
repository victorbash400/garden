import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsToolbar extends StatelessWidget {
  const SettingsToolbar({super.key, required this.label, required this.onBack});
  final String label;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 62,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back to drives',
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFF5F5F7),
            minimumSize: const Size(44, 32),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: const StadiumBorder(),
          ),
          onPressed: onBack,
          icon: const Icon(LucideIcons.chevronLeft, size: 21),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
