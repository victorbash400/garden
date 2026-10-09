import 'package:flutter/material.dart';

import '../../state/file_opening_controller.dart';
import '../../ui/garden_colors.dart';
import 'node_icon.dart';

class FileOpeningPopup extends StatelessWidget {
  const FileOpeningPopup({super.key, required this.controller});
  final FileOpeningController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final node = controller.node;
      final colors = GardenColors.of(context);
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: colors.panel,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        child: SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (node != null) Center(child: NodeIcon(node: node, size: 48)),
                const SizedBox(height: 20),
                Text(
                  'Opening ${node?.name ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    controller.stage,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: colors.secondary),
                  ),
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(minHeight: 2, color: colors.ink),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hide'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
