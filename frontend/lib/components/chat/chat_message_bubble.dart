import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../ui/garden_colors.dart';
import '../file_icon.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.own,
    required this.hasReplies,
    required this.onReply,
    required this.onFile,
  });
  final DriveMessage message;
  final bool own, hasReplies;
  final VoidCallback onReply;
  final ValueChanged<int> onFile;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: own ? colors.selection : colors.hover,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(own ? 18 : 5),
          bottomRight: Radius.circular(own ? 5 : 18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.text.isNotEmpty)
            SelectableText(
              message.text,
              textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(fontSize: 13, height: 1.45, color: colors.ink),
            ),
          if (message.nodeId != null)
            TextButton.icon(
              onPressed: () => onFile(message.nodeId!),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const FileIcon(size: 18),
              label: Text(
                message.nodeName!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          if (hasReplies)
            TextButton(
              onPressed: onReply,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 26),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('View thread', style: TextStyle(fontSize: 11)),
            ),
        ],
      ),
    );
  }
}
