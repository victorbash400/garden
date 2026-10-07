import 'package:flutter/material.dart';

class SettingsTransition extends StatelessWidget {
  const SettingsTransition({
    super.key,
    required this.child,
    this.enabled = true,
  });
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) =>
      !enabled || MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          reverseDuration: const Duration(milliseconds: 100),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (current, previous) =>
              Stack(alignment: Alignment.topCenter, children: [?current]),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (_, child) => Transform.translate(
                offset: Offset(8 * (1 - animation.value), 0),
                child: child,
              ),
            ),
          ),
          child: child,
        );
}
