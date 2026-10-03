import 'package:flutter/material.dart';

import '../../native/finder_updates.dart';
import 'settings_row.dart';

class BackgroundUpdatesRow extends StatelessWidget {
  const BackgroundUpdatesRow({super.key, required this.updates});
  final FinderUpdates updates;

  @override
  Widget build(BuildContext context) => SettingsRow(
    label: 'Background updates',
    value: Text(switch (updates.state) {
      FinderUpdateState.idle => 'No drives',
      FinderUpdateState.connecting => 'Connecting',
      FinderUpdateState.running => 'Running',
      FinderUpdateState.disconnected => 'Disconnected',
    }),
  );
}
