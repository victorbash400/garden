import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../state/file_import_controller.dart';

class ImportStatusBar extends StatelessWidget {
  const ImportStatusBar({super.key, required this.controller});
  final FileImportController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (_, _) {
      if (!controller.busy &&
          controller.error == null &&
          controller.result == null) {
        return const SizedBox.shrink();
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.busy)
            LinearProgressIndicator(value: controller.progress, minHeight: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 10, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.error ??
                        controller.result ??
                        '${controller.committing
                            ? 'Saving'
                            : controller.canCancel
                            ? 'Importing'
                            : 'Cancelling'} ${controller.name ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.error == null
                          ? const Color(0xFF686868)
                          : const Color(0xFFAA3434),
                    ),
                  ),
                ),
                if (controller.busy)
                  TextButton(
                    onPressed: controller.canCancel ? controller.cancel : null,
                    child: const Text('Cancel'),
                  )
                else
                  IconButton(
                    tooltip: 'Dismiss import status',
                    onPressed: controller.dismiss,
                    icon: const Icon(LucideIcons.x, size: 16),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
