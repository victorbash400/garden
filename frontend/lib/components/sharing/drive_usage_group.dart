import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../settings/settings_group.dart';
import '../settings/settings_row.dart';
import '../files/file_size.dart';

class DriveUsageGroup extends StatelessWidget {
  const DriveUsageGroup({super.key, required this.drive});
  final DriveManagement drive;
  @override
  Widget build(BuildContext context) => SettingsGroup(
    children: [
      SettingsRow(
        label: 'Cloud files',
        value: Text(fileSize(drive.logicalBytes)),
      ),
      SettingsRow(label: 'Files', value: Text('${drive.fileCount}')),
      SettingsRow(label: 'Folders', value: Text('${drive.folderCount}')),
      SettingsRow(label: 'Your permission', value: Text(drive.drive.role)),
    ],
  );
}
