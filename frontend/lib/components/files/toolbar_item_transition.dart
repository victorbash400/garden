import 'package:flutter/material.dart';

class ToolbarItemTransition extends StatelessWidget {
  const ToolbarItemTransition({super.key, required this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return child ?? const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 140),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerRight,
        children: [
          for (final item in previous)
            ExcludeFocus(
              child: ExcludeSemantics(child: IgnorePointer(child: item)),
            ),
          ?current,
        ],
      ),
      transitionBuilder: (child, animation) => SizeTransition(
        axis: Axis.horizontal,
        alignment: Alignment.centerRight,
        sizeFactor: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: child == null
          ? const SizedBox.shrink(key: ValueKey(false))
          : KeyedSubtree(key: const ValueKey(true), child: child!),
    );
  }
}
