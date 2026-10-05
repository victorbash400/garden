import 'files/hover_rename.dart';
import 'files/file_actions.dart';

import 'package:flutter/material.dart';
import 'package:garden_client/garden_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../model/garden_info.dart';
import '../state/files_controller.dart';
import 'tree_row.dart';
import 'files/node_drag_surface.dart';

class DriveFolderBranch extends StatefulWidget {
  const DriveFolderBranch({
    super.key,
    required this.controller,
    required this.drive,
    required this.parentId,
    required this.onNavigate,
    this.depth = 1,
  });
  final FilesController controller;
  final GardenInfo drive;
  final int parentId;
  final int depth;
  final Future<void> Function(FileNode) onNavigate;
  @override
  State<DriveFolderBranch> createState() => _DriveFolderBranchState();
}

class _DriveFolderBranchState extends State<DriveFolderBranch> {
  @override
  Widget build(BuildContext context) {
    final files = widget.controller;
    final index = files.folderIndex(widget.drive.id);
    final active = files.drive?.id == widget.drive.id;
    return Column(
      children: [
        for (final node in index.directory(widget.parentId)) ...[
          NodeDragSurface(
            controller: files,
            driveId: widget.drive.id,
            canWrite: widget.drive.canWrite,
            node: node,
            child: HoverRename(
              onRename: files.busy || !widget.drive.canWrite
                  ? null
                  : () async {
                      await widget.onNavigate(node);
                      if (context.mounted) {
                        await FileActions(
                          context,
                          files,
                        ).perform(node, 'rename');
                      }
                    },
              child: TreeRow(
                label: node.name,
                icon: node.kind == NodeKind.folder
                    ? LucideIcons.folder
                    : LucideIcons.file,
                depth: widget.depth,
                selected:
                    active &&
                    (node.kind == NodeKind.folder
                        ? files.parentId == node.id
                        : files.selected?.id == node.id),
                expanded: index.expanded.contains(node.id),
                folderOpen:
                    active && files.path.any((folder) => folder.id == node.id),
                onOpen: files.busy
                    ? null
                    : () async {
                        await widget.onNavigate(node);
                        if (node.kind == NodeKind.folder && mounted) {
                          setState(() => index.expanded.add(node.id!));
                        }
                      },
                onToggle:
                    node.kind != NodeKind.folder ||
                        (index.isLoaded(node.id!) &&
                            !index.hasChildren(node.id!))
                    ? null
                    : () async {
                        if (index.expanded.contains(node.id)) {
                          setState(() => index.expanded.remove(node.id));
                        } else {
                          await files.loadDriveChildren(
                            widget.drive.id,
                            node.id!,
                          );
                          if (mounted && index.isLoaded(node.id!)) {
                            setState(() => index.expanded.add(node.id!));
                          }
                        }
                      },
              ),
            ),
          ),
          if (node.kind == NodeKind.folder && index.expanded.contains(node.id))
            DriveFolderBranch(
              key: ValueKey(node.id),
              controller: files,
              drive: widget.drive,
              parentId: node.id!,
              depth: widget.depth + 1,
              onNavigate: widget.onNavigate,
            ),
        ],
      ],
    );
  }
}
