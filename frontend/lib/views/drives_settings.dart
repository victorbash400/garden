import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../components/settings/settings_group.dart';
import '../components/settings/settings_row.dart';
import '../components/settings/settings_issue.dart';
import '../components/sharing/drive_usage_group.dart';
import '../components/sharing/drive_settings_actions.dart';
import '../components/sharing/drive_picker.dart';
import '../components/sharing/drive_members_group.dart';
import '../components/sharing/drive_invitations_group.dart';
import '../components/sharing/invite_member_dialog.dart';
import '../services/sharing/drive_sharing_service.dart';
import '../state/garden_controller.dart';
import '../utils/error_message.dart';

class DrivesSettings extends StatefulWidget {
  const DrivesSettings({super.key, required this.controller});
  final GardenController controller;
  @override
  State<DrivesSettings> createState() => _DrivesSettingsState();
}

class _DrivesSettingsState extends State<DrivesSettings> {
  int? selected;
  DriveManagement? details;
  String? error;
  bool busy = false;
  bool loading = false;
  bool reload = false;
  int noticeCursor = 0;
  DriveSharingService get service => widget.controller.notifications!.service;
  @override
  void initState() {
    super.initState();
    widget.controller.notifications?.addListener(notificationsChanged);
    if (widget.controller.gardens.isNotEmpty) {
      selected =
          widget.controller.selected?.id ?? widget.controller.gardens.first.id;
      load();
    }
  }

  @override
  void dispose() {
    widget.controller.notifications?.removeListener(notificationsChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(DrivesSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.controller.gardens.any((drive) => drive.id == selected)) {
      selected = widget.controller.gardens.firstOrNull?.id;
      details = null;
      load();
    }
  }

  void notificationsChanged() {
    final items = widget.controller.notifications!.items;
    final changed = items.any(
      (item) =>
          item.id! > noticeCursor &&
          item.gardenId == selected &&
          item.kind == 'accessChanged',
    );
    for (final item in items) {
      if (item.id! > noticeCursor) noticeCursor = item.id!;
    }
    if (changed) load();
  }

  Future<void> load() async {
    if (selected == null) return;
    if (loading) {
      reload = true;
      return;
    }
    loading = true;
    final driveId = selected!;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await service.management(driveId);
      if (mounted && selected == driveId) setState(() => details = result);
    } catch (failure) {
      if (mounted && selected == driveId) {
        setState(() {
          details = null;
          error = errorMessage(failure);
        });
      }
    } finally {
      loading = false;
      if (mounted) setState(() => busy = false);
      if (reload && mounted) {
        reload = false;
        load();
      }
    }
  }

  Future<void> act(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
      await widget.controller.refresh();
      if (widget.controller.error != null) {
        throw StateError(widget.controller.error!);
      }
      if (!mounted) return;
      if (!widget.controller.gardens.any((drive) => drive.id == selected)) {
        setState(() {
          selected = widget.controller.gardens.firstOrNull?.id;
          details = null;
        });
      }
      await load();
    } catch (failure) {
      if (mounted) setState(() => error = errorMessage(failure));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> invite() async {
    final result = await showDialog<DriveInvitation>(
      context: context,
      builder: (_) => InviteMemberDialog(
        service: service,
        driveId: selected!,
        owner: details!.drive.role == 'Owner',
      ),
    );
    if (result != null && mounted) await load();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller.notifications == null) {
      return const Text('Drive sharing is unavailable.');
    }
    if (widget.controller.gardens.isEmpty) {
      return const SettingsGroup(
        children: [SettingsRow(label: 'No drives', value: SizedBox.shrink())],
      );
    }
    final drive = details;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              label: 'Drive',
              value: DrivePicker(
                selected: selected,
                drives: widget.controller.gardens,
                onChanged: busy
                    ? null
                    : (value) {
                        setState(() {
                          selected = value;
                          details = null;
                        });
                        load();
                      },
              ),
            ),
            if (drive != null)
              DriveSettingsActions(
                name: drive.drive.name,
                owner: drive.drive.role == 'Owner',
                busy: busy,
                onRename: (name) => act(() async {
                  final info = widget.controller.gardens.singleWhere(
                    (item) => item.id == selected,
                  );
                  await widget.controller.renameDrive(info, name);
                  if (widget.controller.error != null) {
                    throw StateError(widget.controller.error!);
                  }
                }),
                onRemove: () => act(() async {
                  if (drive.drive.role == 'Owner') {
                    final info = widget.controller.gardens.singleWhere(
                      (item) => item.id == selected,
                    );
                    await widget.controller.deleteDrive(info);
                    if (widget.controller.error != null) {
                      throw StateError(widget.controller.error!);
                    }
                  } else {
                    await service.leave(selected!);
                  }
                }),
              ),
            if (error != null)
              SettingsIssue(message: error!, action: 'Retry', onAction: load),
          ],
        ),
        if (busy && drive == null)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        if (drive != null) ...[
          const SizedBox(height: 20),
          DriveUsageGroup(drive: drive),
          const SizedBox(height: 20),
          DriveMembersGroup(
            drive: drive,
            actorId: widget.controller.account!.id,
            busy: busy,
            onInvite: invite,
            onAction: (member, role) => act(
              () => switch (role) {
                'transfer' => service.transferOwnership(
                  selected!,
                  member.userId,
                ),
                'remove' => service.remove(selected!, member.userId),
                _ => service.changeRole(selected!, member.userId, role),
              },
            ),
          ),
          if (drive.invitations.isNotEmpty) ...[
            const SizedBox(height: 20),
            DriveInvitationsGroup(
              drive: drive,
              busy: busy,
              onResend: (invitation) => act(() async {
                await service.resend(invitation.id!);
              }),
              onRevoke: (invitation) =>
                  act(() => service.revoke(invitation.id!)),
            ),
          ],
        ],
      ],
    );
  }
}
