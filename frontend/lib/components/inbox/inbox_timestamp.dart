import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class InboxTimestamp extends StatelessWidget {
  const InboxTimestamp({super.key, required this.time});
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final local = time.toLocal();
    final now = DateTime.now();
    final today =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    return Text(
      today
          ? '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}'
          : '${local.day}/${local.month}${local.year == now.year ? '' : '/${local.year}'}',
      style: TextStyle(fontSize: 10, color: GardenColors.of(context).secondary),
    );
  }
}
