import 'package:flutter/material.dart';

class DemoAccountButton extends StatelessWidget {
  const DemoAccountButton({super.key, required this.onFill});
  final VoidCallback? onFill;
  static const email = 'demo@garden.local';
  static const password = 'garden-demo';
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onFill,
    style: TextButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      foregroundColor: const Color(0xFF737373),
      textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 12),
    ),
    child: const Text('Use demo account'),
  );
}
