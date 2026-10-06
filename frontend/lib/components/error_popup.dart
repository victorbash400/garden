import 'system_icon.dart';

import 'package:flutter/material.dart';

class ErrorPopup extends StatelessWidget {
  const ErrorPopup({
    super.key,
    required this.message,
    this.action,
    this.onAction,
  });
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outline),
      ),
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemIcon(
                SystemIcons.triangleAlert,
                size: 40,
                color: colors.error,
              ),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: SelectableText(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
