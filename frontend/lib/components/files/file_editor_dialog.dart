import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/file_editor_controller.dart';

class FileEditorDialog extends StatefulWidget {
  const FileEditorDialog({super.key, required this.controller});
  final FileEditorController controller;
  @override
  State<FileEditorDialog> createState() => _FileEditorDialogState();
}

class _FileEditorDialogState extends State<FileEditorDialog> {
  final input = TextEditingController();
  bool initialized = false;
  FileNode? saved;
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  void dispose() {
    input.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      if (controller.loaded && !initialized) {
        input.text = controller.text;
        initialized = true;
      }
      return PopScope(
        canPop: !controller.busy,
        child: AlertDialog(
          title: Text(
            controller.node.name,
            style: const TextStyle(fontSize: 14),
          ),
          content: SizedBox(
            width: 620,
            height: 380,
            child: Column(
              children: [
                if (controller.busy)
                  const LinearProgressIndicator(minHeight: 2),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText(
                      controller.error!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: input,
                    enabled: controller.loaded && !controller.busy,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.busy
                  ? null
                  : () => Navigator.pop(context, saved),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: controller.busy || !controller.loaded
                  ? null
                  : () async {
                      await controller.save(input.text);
                      if (controller.node.version != 0) saved = controller.node;
                      if (context.mounted && controller.error == null) {
                        Navigator.pop(context, saved);
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    },
  );
}
