import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../components/error_notice.dart';
import '../components/files/directory_list.dart';
import '../components/files/file_actions.dart';
import '../components/files/file_details.dart';
import '../components/files/files_toolbar.dart';
import '../state/files_controller.dart';

class FilesView extends StatelessWidget {
  const FilesView({super.key, required this.controller, required this.userId});
  final FilesController controller;
  final String userId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final actions = FileActions(context, controller);
      final selected = controller.selected;
      return ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            FilesToolbar(
              controller: controller,
              onCreate: actions.create,
              onImport: actions.import,
              onInvite: actions.invite,
            ),
            const Divider(height: 1, color: Color(0xFFE8E8EB)),
            if (controller.busy)
              LinearProgressIndicator(minHeight: 2, value: controller.progress),
            if (controller.error != null)
              ErrorNotice(
                message: controller.error!,
                onDismiss: controller.dismissError,
              ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: DirectoryList(controller: controller)),
                  if (selected != null && selected.kind == NodeKind.file)
                    FileDetails(
                      key: ValueKey(selected.id),
                      gateway: controller.gateway,
                      node: selected,
                      revision: controller.revision,
                      userId: userId,
                      onExport: (version) =>
                          actions.export(selected, version: version),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8E8EB)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              child: Row(
                children: [
                  Text(
                    '${controller.nodes.length} ${controller.nodes.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Text(
                    'Finder not mounted',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
