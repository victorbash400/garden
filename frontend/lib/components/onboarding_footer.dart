import 'package:flutter/material.dart';

import 'garden_button.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    this.onBack,
    required this.action,
    this.onAction,
    this.busy = false,
  });
  final VoidCallback? onBack;
  final String action;
  final VoidCallback? onAction;
  final bool busy;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 82,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          if (onBack != null)
            GardenButton(label: 'Back', secondary: true, onPressed: onBack),
          const Spacer(),
          if (busy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            ),
          GardenButton(label: action, onPressed: onAction),
        ],
      ),
    ),
  );
}
