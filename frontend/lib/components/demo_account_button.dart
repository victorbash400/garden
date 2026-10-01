import 'package:flutter/material.dart';

class DemoAccountButton extends StatelessWidget {
  const DemoAccountButton({super.key, required this.onFill});
  final VoidCallback? onFill;
  static const email = 'demo@garden.local';
  static const password = 'garden-demo';
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton(
      onPressed: onFill,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        foregroundColor: const Color(0xFF737373),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: const Text('Use demo account'),
    ),
  );
}
