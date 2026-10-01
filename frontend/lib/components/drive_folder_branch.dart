import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../state/files_controller.dart';
import 'tree_row.dart';
import 'tree_file_row.dart';

class DriveFolderBranch extends StatefulWidget {
  const DriveFolderBranch({
    super.key,
    required this.controller,
    required this.parentId,
    required this.onNavigate,
    this.depth = 1,
  });
  final FilesController controller;
  final int parentId;
  final int depth;
  final VoidCallback onNavigate;
  @override
  State<DriveFolderBranch> createState() => _DriveFolderBranchState();
}

class _DriveFolderBranchState extends State<DriveFolderBranch> {
  final expanded = <int>{};
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final folder in widget.controller.folders.children(
        widget.parentId,
      )) ...[
        TreeRow(
          label: folder.name,
          icon: LucideIcons.folder,
          depth: widget.depth,
          selected: widget.controller.parentId == folder.id,
          expanded: expanded.contains(folder.id),
          onOpen: widget.controller.busy
              ? null
              : () async {
                  await widget.controller.openFolder(folder);
                  if (mounted) setState(() => expanded.add(folder.id!));
                  widget.onNavigate();
                },
          onToggle:
              widget.controller.busy ||
                  !widget.controller.folders.hasChildren(folder.id!)
              ? null
              : () async {
                  if (expanded.contains(folder.id)) {
                    setState(() => expanded.remove(folder.id));
                  } else {
                    await widget.controller.loadFolderChildren(folder.id!);
                    if (mounted && widget.controller.error == null) {
                      setState(() => expanded.add(folder.id!));
                    }
                  }
                },
        ),
        if (expanded.contains(folder.id))
          DriveFolderBranch(
            key: ValueKey(folder.id),
            controller: widget.controller,
            parentId: folder.id!,
            depth: widget.depth + 1,
            onNavigate: widget.onNavigate,
          ),
      ],
      for (final file in widget.controller.folders.files(widget.parentId))
        TreeFileRow(
          node: file,
          controller: widget.controller,
          depth: widget.depth,
          onNavigate: widget.onNavigate,
        ),
    ],
  );
}
