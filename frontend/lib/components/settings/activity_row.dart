import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../model/activity_entry.dart';
import '../list_row.dart';
import 'activity_details.dart';

class ActivityRow extends StatefulWidget {
  const ActivityRow({
    super.key,
    required this.entry,
    required this.drive,
    this.striped = false,
  });
  final ActivityEntry entry;
  final String drive;
  final bool striped;
  @override
  State<ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<ActivityRow> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final time = entry.time.toLocal();
    final clock = [
      time.hour,
      time.minute,
      time.second,
    ].map((value) => value.toString().padLeft(2, '0')).join(':');
    return Column(
      children: [
        ListRow(
          selected: expanded,
          striped: widget.striped,
          onTap: () => setState(() => expanded = !expanded),
          child: SizedBox(
            height: 38,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 650;
                Widget cell(String text, double width, {Color? color}) =>
                    SizedBox(
                      width: width,
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: color ?? GardenColors.of(context).secondary,
                        ),
                      ),
                    );
                return Row(
                  children: [
                    SizedBox(width: 9),
                    SystemIcon(
                      expanded
                          ? SystemIcons.chevronDown
                          : SystemIcons.chevronRight,
                      size: 13,
                      color: GardenColors.of(context).ink,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        entry.name.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    cell(
                      entry.action,
                      92,
                      color: entry.error == null
                          ? null
                          : GardenColors.of(context).danger,
                    ),
                    if (wide) cell(widget.drive, 90),
                    if (wide) cell(entry.source, 112),
                    cell(clock, 66),
                    SizedBox(width: 9),
                  ],
                );
              },
            ),
          ),
        ),
        AnimatedSize(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : Duration(milliseconds: 160),
          alignment: Alignment.topCenter,
          child: expanded
              ? ActivityDetails(entry: entry)
              : SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
