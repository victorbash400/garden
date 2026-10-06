import 'package:flutter/material.dart';

import '../settings/settings_inline_button.dart';

class NotificationActions extends StatelessWidget {
  const NotificationActions({
    super.key,
    required this.pending,
    required this.unread,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onRead,
    required this.onTrash,
    required this.trashed,
  });
  final bool pending, unread, busy, trashed;
  final VoidCallback onAccept, onDecline, onRead, onTrash;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      if (!trashed && pending) ...[
        SettingsInlineButton(
          label: 'Accept',
          primary: true,
          onPressed: busy ? null : onAccept,
        ),
        SettingsInlineButton(
          label: 'Decline',
          onPressed: busy ? null : onDecline,
        ),
      ] else if (!trashed && unread)
        SettingsInlineButton(
          label: 'Mark read',
          onPressed: busy ? null : onRead,
        ),
      SettingsInlineButton(
        label: trashed ? 'Restore' : 'Move to trash',
        onPressed: busy ? null : onTrash,
      ),
    ],
  );
}
