import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../ui/garden_colors.dart';

import '../../services/files/drop_import.dart';
import '../../state/files_controller.dart';

class DirectoryDropTarget extends StatefulWidget {
  const DirectoryDropTarget({
    super.key,
    required this.controller,
    required this.child,
    this.parentId,
  });
  final FilesController controller;
  final Widget child;
  final int? parentId;

  @override
  State<DirectoryDropTarget> createState() => _DirectoryDropTargetState();
}

class _DirectoryDropTargetState extends State<DirectoryDropTarget> {
  bool dragging = false;

  Future<void> _drop(DropDoneDetails details) async {
    setState(() => dragging = false);
    final files = widget.controller;
    final driveId = files.drive!.id;
    final parentId = widget.parentId ?? files.parentId;
    try {
      await DropImport.run(files.imports, driveId, parentId, details.files);
    } catch (failure) {
      files.reportError(failure);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller.imports,
    builder: (_, _) => DropTarget(
      enable: !widget.controller.imports.busy && widget.controller.canWrite,
      onDragEntered: (_) => setState(() => dragging = true),
      onDragExited: (_) => setState(() => dragging = false),
      onDragDone: _drop,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (dragging)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: GardenColors.of(context).accentSurface,
                  border: Border.all(
                    color: GardenColors.of(context).accent,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
