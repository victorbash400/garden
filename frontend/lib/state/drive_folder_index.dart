import 'package:garden_client/garden_client.dart';

class DriveFolderIndex {
  final Map<int, FileNode> _folders = {};
  final Map<int, FileNode> _files = {};
  void clear() {
    _folders.clear();
    _files.clear();
  }

  void remove(int id) {
    _folders.remove(id);
    _files.remove(id);
  }

  void update(FileNode node) {
    if (node.kind == NodeKind.file && !node.deleted) {
      _files[node.id!] = node;
    } else {
      _files.remove(node.id);
    }
    if (node.kind == NodeKind.folder && !node.deleted) {
      _folders[node.id!] = node;
    } else {
      _folders.remove(node.id);
    }
  }

  void replaceDirectory(int parentId, List<FileNode> nodes) {
    _folders.removeWhere((_, node) => node.parentId == parentId);
    _files.removeWhere((_, node) => node.parentId == parentId);
    for (final node in nodes) {
      update(node);
    }
  }

  List<FileNode> children(int parentId) =>
      _folders.values.where((node) => node.parentId == parentId).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  List<FileNode> files(int parentId) =>
      _files.values.where((node) => node.parentId == parentId).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  List<FileNode> pathTo(FileNode folder) {
    final path = <FileNode>[];
    final visited = <int>{};
    FileNode? current = folder;
    while (current != null) {
      if (!visited.add(current.id!)) {
        throw StateError('Invalid folder hierarchy.');
      }
      path.insert(0, current);
      if (current.parentId == 0) return path;
      current = _folders[current.parentId];
    }
    throw StateError('Folder parent is not loaded.');
  }
}
