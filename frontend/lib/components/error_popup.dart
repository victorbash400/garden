import 'warning_icon.dart';
import '../ui/garden_colors.dart';

import 'package:flutter/material.dart';

class ErrorPopup extends StatelessWidget {
  const ErrorPopup({
    super.key,
    required this.message,
    this.action,
    this.onAction,
    this.dismissLabel = 'OK',
    this.canDismiss = true,
  });
  final String message;
  final String? action;
  final VoidCallback? onAction;
  final String dismissLabel;
  final bool canDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return PopScope(
      canPop: canDismiss,
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        child: SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: WarningIcon()),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Semantics(
                      liveRegion: true,
                      child: SelectableText(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: colors.ink, height: 1.45),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (action != null && onAction != null) ...[
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(action!),
                  ),
                  const SizedBox(height: 8),
                ],
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(dismissLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
