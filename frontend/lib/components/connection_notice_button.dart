import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConnectionNoticeButton extends StatelessWidget {
  const ConnectionNoticeButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 32,
    child: IconButton(
      tooltip: 'Connection needs attention',
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: const Badge(
        backgroundColor: Color(0xFFB96032),
        child: Icon(LucideIcons.bell, size: 17),
      ),
    ),
  );
}
