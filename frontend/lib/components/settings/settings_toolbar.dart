import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SettingsToolbar extends StatelessWidget {
  const SettingsToolbar({super.key, required this.label, required this.onBack});
  final String label;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back to drives',
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
