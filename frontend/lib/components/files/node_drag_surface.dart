import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';

class NodeDrag {
  const NodeDrag(this.driveId, this.node);
  final int driveId;
  final FileNode node;
}

class NodeDragSurface extends StatelessWidget {
  const NodeDragSurface({
    super.key,
    required this.controller,
    required this.driveId,
    required this.child,
    this.node,
    this.parentId,
    this.canWrite,
  });
  final FilesController controller;
  final int driveId;
  final FileNode? node;
  final int? parentId;
  final bool? canWrite;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final writable = canWrite ?? controller.canWrite;
    Widget content = child;
    if (node != null && writable) {
      content = Draggable<NodeDrag>(
        data: NodeDrag(driveId, node!),
        allowedButtonsFilter: (buttons) => buttons == 1,
        feedback: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(7),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(node!.name),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: child),
        child: child,
      );
    }
    final destination = node?.kind == NodeKind.folder ? node!.id : parentId;
    if (destination == null) return content;
    return DragTarget<NodeDrag>(
      onWillAcceptWithDetails: (details) =>
          writable &&
          details.data.driveId == driveId &&
          details.data.node.id != destination &&
          details.data.node.parentId != destination,
      onAcceptWithDetails: (details) async {
        try {
          await controller.moveWithin(driveId, details.data.node, destination);
        } catch (failure) {
          controller.reportError(failure);
        }
      },
      builder: (_, candidates, _) => DecoratedBox(
        decoration: BoxDecoration(
          color: candidates.isEmpty
              ? Colors.transparent
              : const Color(0x220078FF),
          borderRadius: BorderRadius.circular(7),
        ),
        child: content,
      ),
    );
  }
}
