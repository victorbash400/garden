import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_inline_button.dart';

class InvitationNotificationRow extends StatefulWidget {
  const InvitationNotificationRow({
    super.key,
    required this.item,
    this.invitation,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onRead,
  });
  final AccountNotification item;
  final DriveInvitation? invitation;
  final bool busy;
  final VoidCallback onAccept, onDecline, onRead;
  @override
  State<InvitationNotificationRow> createState() =>
      _InvitationNotificationRowState();
}

class _InvitationNotificationRowState extends State<InvitationNotificationRow> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final invite = widget.invitation;
    final pending =
        invite != null &&
        invite.acceptedAt == null &&
        invite.declinedAt == null &&
        invite.revokedAt == null &&
        invite.expiresAt.isAfter(DateTime.now().toUtc());
    final status = invite == null
        ? (widget.item.kind == 'accessChanged'
              ? 'Drive access updated'
              : widget.item.kind == 'invitationUpdated'
              ? 'Invitation updated'
              : 'Drive invitation')
        : invite.acceptedAt != null
        ? 'Accepted'
        : invite.declinedAt != null
        ? 'Declined'
        : invite.revokedAt != null
        ? 'Revoked'
        : !pending
        ? 'Expired'
        : 'Drive invitation · ${invite.role}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => expanded = !expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: widget.item.readAt == null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (pending) ...[
                  SettingsInlineButton(
                    label: 'Decline',
                    onPressed: widget.busy ? null : widget.onDecline,
                  ),
                  const SizedBox(width: 8),
                  SettingsInlineButton(
                    label: 'Accept',
                    onPressed: widget.busy ? null : widget.onAccept,
                  ),
                ],
                const SizedBox(width: 12),
                Icon(
                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.createdAt.toLocal().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (widget.item.readAt == null)
                  SettingsInlineButton(
                    label: 'Mark read',
                    onPressed: widget.busy ? null : widget.onRead,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
