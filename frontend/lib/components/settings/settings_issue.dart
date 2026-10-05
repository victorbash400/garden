import 'package:flutter/material.dart';

import '../error_notice.dart';

class SettingsIssue extends StatelessWidget {
  const SettingsIssue({
    super.key,
    required this.message,
    this.details,
    this.action,
    this.onAction,
  });
  final String message;
  final String? details;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => ErrorNotice(
    message: details == null ? message : '$message\n\n$details',
    action: action,
    onAction: onAction,
  );
}
