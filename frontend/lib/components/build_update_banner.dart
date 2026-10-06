import 'system_icon.dart';
import 'package:flutter/material.dart';

import '../native/account_window.dart';

class BuildUpdateBanner extends StatelessWidget {
  const BuildUpdateBanner({super.key, required this.window});
  final AccountWindow window;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: window,
    builder: (context, _) {
      if (window.updateDismissed ||
          (!window.updateReady && window.updateError == null)) {
        return const SizedBox.shrink();
      }
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE2E2E0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SystemIcon(SystemIcons.refreshCw, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    window.updateReady
                        ? 'New build ready'
                        : 'Update unavailable',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  tooltip: 'Dismiss update',
                  onPressed: window.restarting ? null : window.dismissUpdate,
                  icon: const SystemIcon(SystemIcons.x, size: 13),
                  constraints: const BoxConstraints.tightFor(
                    width: 24,
                    height: 24,
                  ),
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            if (window.updateError != null) ...[
              const SizedBox(height: 8),
              Text(
                window.updateError!,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB33930)),
              ),
            ],
            if (window.updateReady) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF252525),
                    backgroundColor: const Color(0xFFF0F0EF),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: window.restarting ? null : window.relaunch,
                  child: Text(
                    window.restarting ? 'Relaunching…' : 'Relaunch',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
