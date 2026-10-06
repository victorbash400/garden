import '../system_icon.dart';

import 'package:flutter/material.dart';

import '../error_notice.dart';

import '../../ui/garden_colors.dart';

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
        return SizedBox.shrink();
      }
      if (controller.error != null) {
        return ErrorNotice(
          message: controller.error!,
          onDismiss: controller.dismiss,
        );
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.busy)
            LinearProgressIndicator(value: controller.progress, minHeight: 2),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 10, 4),
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
                          ? GardenColors.of(context).secondary
                          : GardenColors.of(context).danger,
                    ),
                  ),
                ),
                if (controller.busy)
                  TextButton(
                    onPressed: controller.canCancel ? controller.cancel : null,
                    child: Text('Cancel'),
                  )
                else
                  IconButton(
                    tooltip: 'Dismiss import status',
                    onPressed: controller.dismiss,
                    icon: SystemIcon(SystemIcons.x, size: 16),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
