import 'package:garden_client/garden_client.dart';

import 'drive_folder_index.dart';

class DriveBrowserState {
  const DriveBrowserState({
    required this.folders,
    required this.path,
    required this.selected,
    required this.revision,
  });
  final DriveFolderIndex folders;
  final List<FileNode> path;
  final FileNode? selected;
  final int revision;
}
