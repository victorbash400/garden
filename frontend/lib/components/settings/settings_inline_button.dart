import 'package:flutter/material.dart';

class SettingsInlineButton extends StatelessWidget {
  const SettingsInlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      minimumSize: const Size(0, 30),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      backgroundColor: const Color(0xFFEDEDEE),
      foregroundColor: const Color(0xFF353538),
      disabledBackgroundColor: const Color(0xFFF1F1F2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(fontSize: 12),
    ),
    child: Text(label),
  );
}
