import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../components/sharing/invitation_notification_row.dart';
import '../components/settings/settings_group.dart';
import '../components/settings/settings_issue.dart';
import '../components/sharing/notifications_toolbar.dart';
import '../state/garden_controller.dart';
import '../utils/error_message.dart';
import '../model/notification_filter.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({
    super.key,
    required this.controller,
    this.invitationsOnly = false,
  });
  final GardenController controller;
  final bool invitationsOnly;
  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  Map<int, DriveInvitation> invitations = {};
  String? error;
  bool busy = false;
  NotificationFilter filter = NotificationFilter.all;
  NotificationSort sort = NotificationSort.newest;
  bool loadingInvitations = false;
  bool reloadInvitations = false;
  Map<int, String> inviteStates = {};
  void noticesChanged() {
    final states = {
      for (final item in widget.controller.notifications!.items.where(
        (item) => item.invitationId != null || item.kind == 'invitationUpdated',
      ))
        item.id!: '${item.kind}:${item.readAt}:${item.trashedAt}',
    };
    if (!mapEquals(states, inviteStates)) {
      inviteStates = states;
      load();
    } else if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.notifications?.addListener(noticesChanged);
    load();
  }

  @override
  void dispose() {
    widget.controller.notifications?.removeListener(noticesChanged);
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

  Future<void> act(
    AccountNotification item, {
    bool? accept,
    bool? trashed,
  }) async {
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
      if (trashed != null) {
        await notifications.setTrashed(item, trashed);
      } else {
        await notifications.markRead(item);
      }
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
    final items =
        notifications.items
            .where(
              (item) =>
                  !widget.invitationsOnly ||
                  item.invitationId != null ||
                  item.kind == 'invitationUpdated',
            )
            .where(
              (item) => switch (filter) {
                NotificationFilter.all => item.trashedAt == null,
                NotificationFilter.unread =>
                  item.trashedAt == null && item.readAt == null,
                NotificationFilter.trash => item.trashedAt != null,
              },
            )
            .toList()
          ..sort((a, b) {
            final order = a.createdAt.compareTo(b.createdAt);
            final compared = order == 0 ? a.id!.compareTo(b.id!) : order;
            return sort == NotificationSort.newest ? -compared : compared;
          });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NotificationsToolbar(
          unread: notifications.unread,
          filter: filter,
          sort: sort,
          onFilter: (value) => setState(() => filter = value),
          onSort: (value) => setState(() => sort = value),
          busy: busy || notifications.loading || loadingInvitations,
          onRefresh: () {
            notifications.start();
            load();
          },
        ),
        const SizedBox(height: 12),
        SettingsGroup(
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
              Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!notifications.loading && items.isEmpty)
              Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(switch (filter) {
                    NotificationFilter.all => 'No notifications',
                    NotificationFilter.unread => 'No unread notifications',
                    NotificationFilter.trash => 'Trash is empty',
                  }, style: TextStyle(fontSize: 13)),
                ),
              ),
            for (final item in items)
              InvitationNotificationRow(
                key: ValueKey(item.id),
                item: item,
                onOpen: item.kind == 'chatAdded' || item.kind == 'chatMessage'
                    ? () => widget.controller.openInboxNotification(
                        item.gardenId!,
                        item.conversationId,
                      )
                    : null,
                invitation: invitations[item.invitationId],
                busy: busy,
                onAccept: () => act(item, accept: true),
                onDecline: () => act(item, accept: false),
                onRead: () => act(item),
                onTrash: () => act(item, trashed: item.trashedAt == null),
              ),
          ],
        ),
      ],
    );
  }
}
