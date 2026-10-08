import 'package:flutter/material.dart';

import '../garden_button.dart';

class SetupNavigation extends StatelessWidget {
  const SetupNavigation({
    super.key,
    required this.onLater,
    required this.onContinue,
    required this.lastStep,
    this.onBack,
  });

  final VoidCallback onLater;
  final VoidCallback onContinue;
  final VoidCallback? onBack;
  final bool lastStep;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLater,
              child: const Text('Set up later'),
            ),
          ),
        ),
        if (onBack != null) ...[
          GardenButton(label: 'Back', secondary: true, onPressed: onBack),
          const SizedBox(width: 12),
        ],
        GardenButton(
          label: lastStep ? 'Done' : 'Continue',
          onPressed: onContinue,
        ),
      ],
    ),
  );
}
