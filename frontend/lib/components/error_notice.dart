import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ErrorNotice extends StatelessWidget {
  const ErrorNotice({
    super.key,
    required this.message,
    required this.onDismiss,
  });
  final String message;
  final VoidCallback onDismiss;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(28, 12, 28, 0),
    padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F0),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(LucideIcons.circleAlert, size: 16, color: Color(0xFFAA3434)),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFFAA3434)),
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          tooltip: 'Dismiss error',
          icon: const Icon(LucideIcons.x, size: 16),
        ),
      ],
    ),
  );
}
