import 'package:flutter/material.dart';

import 'garden_button.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    this.onBack,
    required this.step,
    required this.totalSteps,
    required this.action,
    this.onAction,
    this.busy = false,
  });
  final VoidCallback? onBack;
  final int step;
  final int totalSteps;
  final String action;
  final VoidCallback? onAction;
  final bool busy;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 82,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$step of $totalSteps',
            style: const TextStyle(color: Color(0xFF737373), fontSize: 13),
          ),
          if (onBack != null)
            Align(
              alignment: Alignment.centerLeft,
              child: GardenButton(
                label: 'Back',
                secondary: true,
                onPressed: onBack,
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        ],
      ),
    ),
  );
}
