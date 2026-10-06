import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import 'package:garden_client/garden_client.dart';

class FileCommentsList extends StatelessWidget {
  const FileCommentsList({
    super.key,
    required this.comments,
    required this.userId,
    this.identities = const {},
  });
  final List<FileComment> comments;
  final String userId;
  final Map<String, String> identities;
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final comment in comments)
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorId == userId
                    ? 'You'
                    : identities[comment.authorId] ?? 'Username unavailable',
                style: TextStyle(
                  fontSize: 11,
                  color: GardenColors.of(context).secondary,
                ),
              ),
              SizedBox(height: 4),
              SelectableText(comment.text, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
    ],
  );
}
