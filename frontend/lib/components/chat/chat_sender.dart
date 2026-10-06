import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

class ChatSender extends StatelessWidget {
  const ChatSender({super.key, required this.username, required this.time});
  final String username;
  final DateTime time;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (username.isNotEmpty)
        Flexible(
          child: Text(
            username,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      if (username.isNotEmpty) const SizedBox(width: 8),
      Text(
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        style: TextStyle(
          fontSize: 10,
          color: GardenColors.of(context).secondary,
        ),
      ),
    ],
  );
}
