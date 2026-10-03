import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/files_controller.dart';
import 'file_actions.dart';

class FileKeyboardBindings extends StatelessWidget {
  const FileKeyboardBindings({
    super.key,
    required this.controller,
    required this.child,
  });
  final FilesController controller;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final actions = FileActions(context, controller);
    void selected(String action) {
      final node = controller.selected;
      if (node != null) actions.perform(node, action);
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
            controller.setViewMode(FileViewMode.grid),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
            controller.setViewMode(FileViewMode.list),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
            controller.setViewMode(FileViewMode.columns),
        const SingleActivator(LogicalKeyboardKey.keyO, meta: true): () =>
            selected('open'),
        const SingleActivator(LogicalKeyboardKey.backspace, meta: true): () =>
            selected('delete'),
        const SingleActivator(LogicalKeyboardKey.enter): () =>
            selected('rename'),
        const SingleActivator(
          LogicalKeyboardKey.keyN,
          meta: true,
          shift: true,
        ): () =>
            actions.create('folder'),
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
