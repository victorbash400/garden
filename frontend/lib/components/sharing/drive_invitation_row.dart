import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_inline_button.dart';

class DriveInvitationRow extends StatelessWidget {
  const DriveInvitationRow({
    super.key,
    required this.invitation,
    required this.busy,
    required this.onResend,
    required this.onRevoke,
  });
  final DriveInvitation invitation;
  final bool busy;
  final VoidCallback onResend, onRevoke;
  @override
  Widget build(BuildContext context) {
    final pending =
        invitation.acceptedAt == null &&
        invitation.declinedAt == null &&
        invitation.revokedAt == null &&
        invitation.expiresAt.isAfter(DateTime.now().toUtc());
    final status = invitation.acceptedAt != null
        ? 'Accepted'
        : invitation.declinedAt != null
        ? 'Declined'
        : invitation.revokedAt != null
        ? 'Revoked'
        : !pending
        ? 'Expired'
        : switch (invitation.deliveryStatus) {
            'accepted' => 'Email accepted by provider',
            'queued' => 'Email queued',
            'failed' => 'Email failed',
            'notConfigured' => 'Email sending needs setup',
            _ => invitation.deliveryStatus,
          };
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitation.recipientEmail,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${invitation.role} · $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (pending && invitation.deliveryError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    invitation.deliveryError!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (pending) ...[
            SettingsInlineButton(
              label: 'Resend',
              onPressed: busy ? null : onResend,
            ),
            const SizedBox(width: 8),
            SettingsInlineButton(
              label: 'Revoke',
              onPressed: busy ? null : onRevoke,
            ),
          ],
        ],
      ),
    );
  }
}
