import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../components/sharing/invitation_notification_row.dart';
import '../components/settings/settings_group.dart';
import '../components/settings/settings_issue.dart';
import '../components/settings/settings_row.dart';
import '../components/settings/settings_inline_button.dart';
import '../state/garden_controller.dart';
import '../utils/error_message.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  Map<int, DriveInvitation> invitations = {};
  String? error;
  bool busy = false;
  bool loadingInvitations = false;
  bool reloadInvitations = false;
  @override
  void initState() {
    super.initState();
    widget.controller.notifications?.addListener(load);
    load();
  }

  @override
  void dispose() {
    widget.controller.notifications?.removeListener(load);
    super.dispose();
  }

  Future<void> load() async {
    if (loadingInvitations) {
      reloadInvitations = true;
      return;
    }
    loadingInvitations = true;
    try {
      final values = await widget.controller.notifications!.service.received();
      if (mounted) {
        setState(() {
          invitations = {for (final value in values) value.id!: value};
          error = null;
        });
      }
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      loadingInvitations = false;
      if (reloadInvitations && mounted) {
        reloadInvitations = false;
        load();
      }
    }
  }

  Future<void> act(AccountNotification item, {bool? accept}) async {
    setState(() {
      busy = true;
      error = null;
    });
    final notifications = widget.controller.notifications!;
    try {
      if (accept == true) {
        await notifications.service.accept(item.invitationId!);
      }
      if (accept == false) {
        await notifications.service.decline(item.invitationId!);
      }
      await notifications.markRead(item);
      await load();
      if (accept == true) {
        await widget.controller.refresh();
        if (widget.controller.error != null) {
          throw StateError(widget.controller.error!);
        }
      }
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = widget.controller.notifications;
    if (notifications == null) {
      return const Text('Notifications are unavailable.');
    }
    return SettingsGroup(
      children: [
        if (error ?? notifications.error case final String message)
          SettingsIssue(
            message: message,
            action: 'Retry',
            onAction: () {
              notifications.start();
              load();
            },
          ),
        if (notifications.loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (!notifications.loading && notifications.items.isEmpty)
          const SettingsRow(
            label: 'No notifications',
            value: SizedBox.shrink(),
          ),
        for (final item in notifications.items)
          InvitationNotificationRow(
            key: ValueKey(item.id),
            item: item,
            invitation: invitations[item.invitationId],
            busy: busy,
            onAccept: () => act(item, accept: true),
            onDecline: () => act(item, accept: false),
            onRead: () => act(item),
          ),
        SettingsRow(
          label: 'Notifications',
          value: SettingsInlineButton(
            label: 'Refresh',
            onPressed: busy
                ? null
                : () {
                    notifications.start();
                    load();
                  },
          ),
        ),
      ],
    );
  }
}
