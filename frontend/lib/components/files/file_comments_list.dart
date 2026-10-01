import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

class FileCommentsList extends StatelessWidget {
  const FileCommentsList({
    super.key,
    required this.comments,
    required this.userId,
  });
  final List<FileComment> comments;
  final String userId;
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final comment in comments)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorId == userId ? 'You' : comment.authorId,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              SelectableText(
                comment.text,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
    ],
  );
}
