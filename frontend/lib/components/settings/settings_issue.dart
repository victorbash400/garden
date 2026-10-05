import 'package:flutter/material.dart';

import 'settings_inline_button.dart';

class SettingsIssue extends StatefulWidget {
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
  State<SettingsIssue> createState() => _SettingsIssueState();
}

class _SettingsIssueState extends State<SettingsIssue> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: Color(0xFFB33D38)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.message,
                style: const TextStyle(fontSize: 12, color: Color(0xFFB33D38)),
              ),
            ),
            if (widget.details != null) ...[
              const SizedBox(width: 12),
              SettingsInlineButton(
                label: expanded ? 'Hide details' : 'Details',
                onPressed: () => setState(() => expanded = !expanded),
              ),
            ],
            if (widget.action != null) ...[
              const SizedBox(width: 8),
              SettingsInlineButton(
                label: widget.action!,
                onPressed: widget.onAction,
              ),
            ],
          ],
        ),
        if (expanded && widget.details != null) ...[
          const SizedBox(height: 12),
          SelectableText(widget.details!, style: const TextStyle(fontSize: 12)),
        ],
      ],
    ),
  );
}
