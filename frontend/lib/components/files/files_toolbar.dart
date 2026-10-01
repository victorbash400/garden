import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/files_controller.dart';

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
    height: 62,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          IconButton(
            tooltip: controller.path.isEmpty
                ? 'Back to drives'
                : 'Parent folder',
            onPressed: controller.busy
                ? null
                : controller.path.isEmpty
                ? onBackToDrives
                : () => controller.goTo(controller.path.length - 1),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(LucideIcons.chevronLeft, size: 18),
          ),
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
                      overlayColor: Colors.transparent,
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
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(controller.path[i].name),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!controller.live)
            IconButton(
              tooltip: 'Reconnect live updates',
              onPressed: controller.busy ? null : controller.reconnect,
              icon: const Icon(LucideIcons.wifiOff, size: 17),
            ),
          if (controller.drive!.role == 'Owner')
            IconButton(
              tooltip: 'Create invitation',
              onPressed: controller.busy ? null : onInvite,
              icon: const Icon(LucideIcons.link, size: 18),
            ),
          IconButton(
            tooltip: 'Import file',
            onPressed: controller.busy ? null : onImport,
            icon: const Icon(LucideIcons.upload, size: 18),
          ),
          PopupMenuButton<String>(
            tooltip: 'Create',
            enabled: !controller.busy,
            icon: const Icon(LucideIcons.plus, size: 19),
            onSelected: onCreate,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'folder', child: Text('New folder…')),
              PopupMenuItem(value: 'file', child: Text('New text file…')),
            ],
          ),
        ],
      ),
    ),
  );
}
