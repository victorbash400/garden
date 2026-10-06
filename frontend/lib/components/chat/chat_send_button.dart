import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../system_icon.dart';

class ChatSendButton extends StatelessWidget {
  const ChatSendButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return IconButton(
      tooltip: 'Send message',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        fixedSize: const Size(30, 30),
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        backgroundColor: colors.ink,
        foregroundColor: colors.surface,
        disabledBackgroundColor: colors.disabled,
        disabledForegroundColor: colors.surface,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const SystemIcon(SystemIcons.arrowUp, size: 16),
    );
  }
}
