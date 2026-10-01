import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/files_controller.dart';
import 'toolbar_button.dart';
import 'toolbar_group.dart';

class FilesToolbar extends StatelessWidget {
  const FilesToolbar({
    super.key,
    required this.controller,
    required this.onCreate,
    required this.onImport,
    required this.onInvite,
    required this.onBackToDrives,
  });
  final FilesController controller;
  final ValueChanged<String> onCreate;
  final VoidCallback onImport;
  final VoidCallback onInvite;
  final VoidCallback onBackToDrives;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          ToolbarGroup(
            children: [
              ToolbarButton(
                tooltip: controller.path.isEmpty
                    ? 'Back to drives'
                    : 'Parent folder',
                onPressed: controller.busy
                    ? null
                    : controller.path.isEmpty
                    ? onBackToDrives
                    : () => controller.goTo(controller.path.length - 1),
                icon: LucideIcons.arrowLeft,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TextButton(
                    onPressed: controller.busy
                        ? null
                        : () => controller.goTo(0),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF333330),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: Theme.of(context).textTheme.labelLarge!
                          .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      overlayColor: const Color(0xFFF9F9F9),
                    ),
                    child: Text(
                      controller.drive!.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  for (var i = 0; i < controller.path.length; i++) ...[
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 12,
                      color: Colors.grey,
                    ),
                    TextButton(
                      onPressed: controller.busy
                          ? null
                          : () => controller.goTo(i + 1),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF333330),
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: Theme.of(context).textTheme.labelLarge!
                            .copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        overlayColor: const Color(0xFFF9F9F9),
                      ),
                      child: Text(controller.path[i].name),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ToolbarGroup(
            children: [
              if (!controller.live)
                ToolbarButton(
                  tooltip: 'Reconnect live updates',
                  onPressed: controller.busy ? null : controller.reconnect,
                  icon: LucideIcons.wifiOff,
                ),
              if (controller.drive!.role == 'Owner')
                ToolbarButton(
                  tooltip: 'Create invitation',
                  onPressed: controller.busy ? null : onInvite,
                  icon: LucideIcons.link,
                ),
              ToolbarButton(
                tooltip: 'Import file',
                onPressed: controller.busy ? null : onImport,
                icon: LucideIcons.upload,
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: PopupMenuButton<String>(
                  tooltip: 'Create',
                  enabled: !controller.busy,
                  padding: EdgeInsets.zero,
                  style: ToolbarButton.style,
                  icon: const Icon(
                    LucideIcons.plus,
                    size: 15,
                    color: Color(0xFF4E4E4A),
                  ),
                  onSelected: onCreate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: const Color(0xFFF5F5F3),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'folder', child: Text('New folder…')),
                    PopupMenuItem(value: 'file', child: Text('New text file…')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
