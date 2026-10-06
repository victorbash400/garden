import 'package:flutter/material.dart';

import '../error_popup.dart';
import 'settings_inline_button.dart';
import 'settings_row.dart';

class ConnectionIssueRow extends StatelessWidget {
  const ConnectionIssueRow({super.key, required this.details});
  final String details;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Connection status',
    value: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(child: Text('Needs attention')),
        const SizedBox(width: 12),
        SettingsInlineButton(
          label: 'Details',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                ErrorPopup(message: 'Connection check failed\n\n$details'),
          ),
        ),
      ],
    ),
  );
}
