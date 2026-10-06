import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../list_row.dart';
import '../system_icon.dart';

class ChatRecipientRow extends StatelessWidget {
  const ChatRecipientRow({
    super.key,
    required this.member,
    required this.selected,
    required this.onChanged,
  });
  final PublicIdentity member;
  final bool selected;
  final VoidCallback? onChanged;
  @override
  Widget build(BuildContext context) => ListRow(
    selected: selected,
    onTap: onChanged,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [
          const SystemIcon(SystemIcons.userRound, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(member.username, style: const TextStyle(fontSize: 13)),
          ),
          if (selected) const SystemIcon(SystemIcons.check, size: 16),
        ],
      ),
    ),
  );
}
