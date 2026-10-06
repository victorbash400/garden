import 'package:flutter/material.dart';

import '../system_icon.dart';

class ConversationAvatar extends StatelessWidget {
  const ConversationAvatar({super.key, this.group = false, this.size = 34});
  final bool group;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Center(
      child: SystemIcon(
        group ? SystemIcons.users : SystemIcons.userRound,
        size: size * .65,
      ),
    ),
  );
}
