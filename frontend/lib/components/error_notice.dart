import 'package:flutter/material.dart';

import 'error_popup.dart';

// Serializes errors from independent surfaces within each app window.
final _pendingErrors = Expando<Future<void>>();

class ErrorNotice extends StatefulWidget {
  const ErrorNotice({
    super.key,
    required this.message,
    this.onDismiss,
    this.action,
    this.onAction,
    this.dismissLabel = 'OK',
    this.canDismiss = true,
  });
  final String message;
  final VoidCallback? onDismiss;
  final String? action;
  final VoidCallback? onAction;
  final String dismissLabel;
  final bool canDismiss;

  @override
  State<ErrorNotice> createState() => _ErrorNoticeState();
}

class _ErrorNoticeState extends State<ErrorNotice> {
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    schedule();
  }

  @override
  void didUpdateWidget(ErrorNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message ||
        oldWidget.canDismiss != widget.canDismiss ||
        oldWidget.dismissLabel != widget.dismissLabel) {
      schedule();
    }
  }

  void schedule() {
    final message = widget.message;
    final generation = ++_generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _generation) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      if (!widget.canDismiss) navigator.popUntil((route) => route.isFirst);
      final previous = _pendingErrors[navigator] ?? Future<void>.value();
      _pendingErrors[navigator] = previous.then((_) async {
        if (!mounted || generation != _generation || widget.message != message) {
          return;
        }
        final retry = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ErrorPopup(
            message: message,
            action: widget.action,
            onAction: widget.onAction,
            dismissLabel: widget.dismissLabel,
            canDismiss: widget.canDismiss,
          ),
        );
        if (!mounted || generation != _generation || widget.message != message) {
          return;
        }
        if (retry == true) {
          widget.onAction?.call();
        } else {
          widget.onDismiss?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
