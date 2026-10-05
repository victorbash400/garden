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
  });
  final String message;
  final VoidCallback? onDismiss;
  final String? action;
  final VoidCallback? onAction;

  @override
  State<ErrorNotice> createState() => _ErrorNoticeState();
}

class _ErrorNoticeState extends State<ErrorNotice> {
  @override
  void initState() {
    super.initState();
    schedule();
  }

  @override
  void didUpdateWidget(ErrorNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) schedule();
  }

  void schedule() {
    final message = widget.message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      final previous = _pendingErrors[navigator] ?? Future<void>.value();
      _pendingErrors[navigator] = previous.then((_) async {
        if (!mounted || widget.message != message) return;
        final retry = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => ErrorPopup(
            message: message,
            action: widget.action,
            onAction: widget.onAction,
          ),
        );
        if (!mounted || widget.message != message) return;
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
