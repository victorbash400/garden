import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';
import '../system_icon.dart';
import 'toolbar_button.dart';

class FilesToolbarBackButton extends StatelessWidget {
  const FilesToolbarBackButton({
    super.key,
    required this.tooltip,
    required this.onPressed,
  });

  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = GardenColors.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: ToolbarButton.style(context).copyWith(
        shape: WidgetStatePropertyAll(
          CircleBorder(side: BorderSide(color: colors.border)),
        ),
        backgroundColor: WidgetStatePropertyAll(colors.sidebar),
      ),
      icon: const SystemIcon(SystemIcons.arrowLeft, size: 16),
    );
  }
}
