import 'system_icon.dart';

import 'package:flutter/material.dart';

import '../native/account_window.dart';
import '../ui/garden_colors.dart';

class BuildUpdateBanner extends StatelessWidget {
  const BuildUpdateBanner({
    super.key,
    required this.window,
    this.onDark = false,
  });
  final AccountWindow window;
  final bool onDark;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: window,
    builder: (context, _) {
      if (window.updateDismissed ||
          (!window.updateReady && window.updateError == null)) {
        return const SizedBox.shrink();
      }
      final colors = GardenColors.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: window.updateReady && !window.restarting
                        ? window.relaunch
                        : null,
                    style: TextButton.styleFrom(
                      foregroundColor: onDark
                          ? const Color(0xFFF2F5EE)
                          : colors.ink,
                      backgroundColor: Colors.transparent,
                      disabledForegroundColor: onDark
                          ? const Color(0xFFD4DCCE)
                          : colors.secondary,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      textStyle: Theme.of(context).textTheme.labelLarge!
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            window.restarting
                                ? 'Relaunching…'
                                : window.updateReady
                                ? 'Software Update Available'
                                : 'Update unavailable',
                            maxLines: 2,
                          ),
                        ),
                        if (window.updateReady && !window.restarting) ...[
                          const SizedBox(width: 8),
                          const Badge(
                            backgroundColor: Color(0xFFFF575D),
                            textColor: Colors.white,
                            largeSize: 18,
                            textStyle: TextStyle(fontSize: 11),
                            label: Text('1'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Dismiss update',
                  onPressed: window.restarting ? null : window.dismissUpdate,
                  icon: SystemIcon(
                    SystemIcons.x,
                    size: 13,
                    color: onDark ? const Color(0xFFD4DCCE) : colors.secondary,
                  ),
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            if (window.updateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  window.updateError!,
                  style: TextStyle(
                    fontSize: 12,
                    color: onDark ? const Color(0xFFFF8E77) : colors.danger,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}
