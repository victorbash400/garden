import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../model/drive_storage_usage.dart';
import '../../services/drive_storage_usage.dart';
import '../../services/sharing/drive_sharing_service.dart';
import '../../utils/error_message.dart';
import '../system_icon.dart';
import 'settings_icon_button.dart';
import 'cache_usage_bar.dart';
import 'settings_group.dart';
import 'settings_issue.dart';
import 'settings_row.dart';

class DriveStorageUsageControls extends StatefulWidget {
  const DriveStorageUsageControls({
    super.key,
    required this.service,
    required this.driveIds,
  });
  final DriveSharingService service;
  final List<int> driveIds;

  @override
  State<DriveStorageUsageControls> createState() => _DriveStorageUsageState();
}

class _DriveStorageUsageState extends State<DriveStorageUsageControls> {
  late Future<List<DriveStorageUsage>> request = _read();
  Future<List<DriveStorageUsage>> _read() =>
      readDriveStorage(widget.service, widget.driveIds);

  @override
  void didUpdateWidget(DriveStorageUsageControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service ||
        !listEquals(oldWidget.driveIds, widget.driveIds)) {
      request = _read();
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: request,
    builder: (context, snapshot) {
      final busy = snapshot.connectionState != ConnectionState.done;
      final usage = snapshot.data;
      return SettingsGroup(
        children: [
          SettingsRow(
            label: 'Files in your drives',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  busy
                      ? 'Loading…'
                      : usage == null
                      ? 'Unavailable'
                      : CacheUsageBar.bytes(
                          usage.fold<int>(0, (sum, drive) => sum + drive.bytes),
                        ),
                ),
                const SizedBox(width: 8),
                SettingsIconButton(
                  tooltip: 'Refresh storage usage',
                  onPressed: busy
                      ? null
                      : () => setState(() {
                          request = _read();
                        }),
                  icon: SystemIcons.refreshCw,
                ),
              ],
            ),
          ),
          if (!busy && snapshot.hasError)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SettingsIssue(
                message: 'Storage request failed',
                details: errorMessage(snapshot.error!),
              ),
            ),
          if (!busy && usage != null)
            for (final drive in usage)
              SettingsRow(
                label: drive.name,
                value: Text(
                  '${CacheUsageBar.bytes(drive.bytes)} · ${drive.files} ${drive.files == 1 ? 'file' : 'files'}',
                ),
              ),
        ],
      );
    },
  );
}
