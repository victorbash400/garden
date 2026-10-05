import 'package:flutter/material.dart';

class ProfileHelpDialog extends StatelessWidget {
  const ProfileHelpDialog({super.key});

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Keyboard shortcuts'),
    content: SizedBox(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final shortcut in const {
            'New account window': '⌘N',
            'Settings': '⌘,',
            'Close window': '⌘W',
            'Icon view': '⌘1',
            'List view': '⌘2',
            'Column view': '⌘3',
          }.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(shortcut.key)),
                  Text(shortcut.value),
                ],
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Done'),
      ),
    ],
  );
}
