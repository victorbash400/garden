import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../model/activity_entry.dart';

class ActivityDetails extends StatelessWidget {
  const ActivityDetails({super.key, required this.entry});
  final ActivityEntry entry;
  @override
  Widget build(BuildContext context) {
    final time = entry.time.toLocal();
    return Padding(
      padding: EdgeInsets.fromLTRB(32, 6, 16, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SelectableText(
          [
            if (entry.name.contains('/')) entry.name,
            time.toString(),
            if (entry.bytes > 0)
              '${entry.bytes} bytes${entry.action == 'Read' ? ' · ${entry.count} ${entry.count == 1 ? 'read' : 'reads'}' : ''}',
            if (entry.milliseconds > 0)
              '${entry.milliseconds.toStringAsFixed(1)} ms${entry.count > 1 ? ' total' : ''}',
            if (entry.error != null) entry.error!,
          ].join('\n'),
          style: TextStyle(
            fontSize: 12,
            height: 1.6,
            color: GardenColors.of(context).secondary,
          ),
        ),
      ),
    );
  }
}
