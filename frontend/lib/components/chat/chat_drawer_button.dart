import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../ui/garden_colors.dart';
import '../files/toolbar_button.dart';

class ChatDrawerButton extends StatelessWidget {
  const ChatDrawerButton({
    super.key,
    required this.open,
    required this.onPressed,
  });
  final bool open;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: open ? 'Close chats' : 'Chats',
    onPressed: onPressed,
    style: ToolbarButton.style(context),
    icon: SvgPicture.asset(
      'assets/icons/lucide-${open ? 'panel-left-close' : 'panel-left'}.svg',
      width: 17,
      height: 17,
      excludeFromSemantics: true,
      colorFilter: ColorFilter.mode(
        GardenColors.of(context).icon,
        BlendMode.srcIn,
      ),
    ),
  );
}
