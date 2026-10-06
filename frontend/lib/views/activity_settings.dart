import 'package:flutter/material.dart';

import '../ui/garden_colors.dart';

import '../state/activity_controller.dart';
import '../state/garden_controller.dart';
import '../components/settings/activity_row.dart';
import '../components/settings/settings_inline_button.dart';
import '../components/settings/settings_issue.dart';
import '../components/settings/activity_header.dart';

class ActivitySettings extends StatefulWidget {
  const ActivitySettings({super.key, required this.controller});
  final GardenController controller;
  @override
  State<ActivitySettings> createState() => _ActivitySettingsState();
}

class _ActivitySettingsState extends State<ActivitySettings> {
  final scroll = ScrollController();
  late final activity = ActivityController(widget.controller.account!.id);
  @override
  void dispose() {
    activity.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: activity,
    builder: (context, _) {
      final entries = activity.entries;
      final drives = {
        for (final drive in widget.controller.gardens) drive.id: drive.name,
      };
      return Material(
        color: GardenColors.of(context).panel,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: GardenColors.of(context).border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Text(
                        '${entries.length} events',
                        style: TextStyle(
                          fontSize: 12,
                          color: GardenColors.of(context).secondary,
                        ),
                      ),
                      Spacer(),
                      SettingsInlineButton(
                        label: 'Clear',
                        onPressed: activity.connected && entries.isNotEmpty
                            ? activity.clear
                            : null,
                      ),
                    ],
                  ),
                ),
                if (activity.error != null)
                  SettingsIssue(
                    message: 'Activity unavailable',
                    details: activity.error,
                    action: 'Retry',
                    onAction: activity.retry,
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: ActivityHeader(),
            ),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Text(
                        activity.connected ? 'No activity yet' : 'Connecting…',
                        style: TextStyle(
                          fontSize: 13,
                          color: GardenColors.of(context).secondary,
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: scroll,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: scroll,
                        padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: entries.length,
                        itemBuilder: (context, index) => ActivityRow(
                          key: ValueKey(entries[index].id),
                          entry: entries[index],
                          striped: index.isOdd,
                          drive:
                              drives[entries[index].drive] ??
                              'Drive ${entries[index].drive}',
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    },
  );
}
