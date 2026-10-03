import 'package:flutter/material.dart';

import '../../state/files_controller.dart';
import 'directory_column.dart';

class DirectoryColumns extends StatefulWidget {
  const DirectoryColumns({super.key, required this.controller});
  final FilesController controller;
  @override
  State<DirectoryColumns> createState() => _DirectoryColumnsState();
}

class _DirectoryColumnsState extends State<DirectoryColumns> {
  final scroll = ScrollController();
  late int depth = widget.controller.path.length;
  @override
  void didUpdateWidget(DirectoryColumns oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (depth == widget.controller.path.length) return;
    depth = widget.controller.path.length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) {
      final count = widget.controller.path.length + 1;
      final width = (constraints.maxWidth / count).clamp(
        240.0,
        double.infinity,
      );
      return SingleChildScrollView(
        controller: scroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var depth = 0; depth < count; depth++)
              DirectoryColumn(
                controller: widget.controller,
                depth: depth,
                width: width,
              ),
          ],
        ),
      );
    },
  );
}
