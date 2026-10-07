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
    this.groupStart = true,
    this.groupEnd = true,
  });
  final DriveMessage message;
  final bool own, hasReplies, groupStart, groupEnd;
  final VoidCallback onReply;
  final ValueChanged<int> onFile;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: own ? colors.selection : colors.hover,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(!own && !groupStart ? 6 : 18),
          topRight: Radius.circular(own && !groupStart ? 6 : 18),
          bottomLeft: Radius.circular(!own && groupEnd ? 5 : 18),
          bottomRight: Radius.circular(own && groupEnd ? 5 : 18),
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
              style: TextStyle(fontSize: 13, height: 1.35, color: colors.ink),
            ),
          if (message.nodeId != null)
            TextButton.icon(
              onPressed: () => onFile(message.nodeId!),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: FileIcon(size: 18, name: message.nodeName),
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
