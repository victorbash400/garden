import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../ui/garden_colors.dart';
import 'notification_actions.dart';
import 'notification_icon.dart';

class InvitationNotificationRow extends StatelessWidget {
  const InvitationNotificationRow({
    super.key,
    required this.item,
    this.invitation,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onRead,
    required this.onTrash,
  });
  final AccountNotification item;
  final DriveInvitation? invitation;
  final bool busy;
  final VoidCallback onAccept, onDecline, onRead, onTrash;
  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    final localDate = item.createdAt.toLocal();
    final locale = MaterialLocalizations.of(context);
    final date =
        '${locale.formatMediumDate(localDate)} · ${locale.formatTimeOfDay(TimeOfDay.fromDateTime(localDate))}';
    final invite = invitation;
    final pending =
        invite != null &&
        invite.acceptedAt == null &&
        invite.declinedAt == null &&
        invite.revokedAt == null &&
        invite.expiresAt.isAfter(DateTime.now().toUtc());
    final status = invite == null
        ? (item.kind == 'accessChanged'
              ? 'Drive access updated'
              : item.kind == 'invitationUpdated'
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: NotificationIcon(
              unread: item.readAt == null && item.trashedAt == null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: TextStyle(fontSize: 12, color: colors.secondary),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: TextStyle(fontSize: 11, color: colors.secondary),
                ),
                ...[
                  const SizedBox(height: 12),
                  NotificationActions(
                    pending: pending && item.trashedAt == null,
                    trashed: item.trashedAt != null,
                    onTrash: onTrash,
                    unread: item.readAt == null,
                    busy: busy,
                    onAccept: onAccept,
                    onDecline: onDecline,
                    onRead: onRead,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
