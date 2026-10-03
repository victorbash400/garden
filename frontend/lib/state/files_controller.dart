import 'dart:async';

import 'drive_folder_index.dart';
import 'drive_browser_state.dart';
import 'file_import_controller.dart';

import '../utils/error_message.dart';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../model/garden_info.dart';
import '../services/files/files_gateway.dart';

class FilesController extends ChangeNotifier {
  FilesController(this.gateway) {
    imports = FileImportController(gateway, _acceptImported);
  }
  final FilesGateway gateway;
  late final FileImportController imports;
  final Map<int, DriveBrowserState> _sessions = {};
  var folders = DriveFolderIndex();
  GardenInfo? drive;
  List<FileNode> nodes = [];
  List<FileNode> path = [];
  FileNode? selected;
  bool busy = false;
  bool live = false;
  String? error;
  int revision = 0;
  double? progress;
  StreamSubscription<DriveEvent>? _subscription;
  List<DriveEvent>? _buffer;
  List<DriveEvent>? _treeBuffer;
  int _generation = 0;
  int get parentId => path.isEmpty ? 0 : path.last.id!;

  Future<void> open(GardenInfo garden) async {
    if (drive?.id == garden.id) return;
    if (drive != null) {
      if (!live) folders.invalidate();
      _sessions[drive!.id] = DriveBrowserState(
        folders: folders,
        path: path.toList(),
        selected: selected,
        revision: revision,
      );
    }
    await _detach();
    drive = garden;
    final session = _sessions.remove(garden.id);
    if (session != null) {
      folders = session.folders;
      path = session.path;
      selected = session.selected;
      revision = session.revision;
      if (folders.isLoaded(parentId)) {
        nodes = folders.directory(parentId);
        _sort();
        _subscribe(garden.id, revision);
        notifyListeners();
        return;
      }
    }
    await _request(() async {
      _buffer = [];
      await _load();
      _subscribe(garden.id, revision);
    });
  }

  Future<void> _load() async {
    final generation = _generation;
    _buffer ??= [];
    late DirectoryListing listing;
    try {
      listing = await gateway.list(drive!.id, parentId);
    } catch (_) {
      _buffer = null;
      rethrow;
    }
    if (generation != _generation) return;
    nodes = listing.nodes;
    folders.replaceDirectory(parentId, nodes);
    if (_subscription == null) revision = listing.revision;
    selected = null;
    final events = _buffer!;
    _buffer = null;
    for (final event in events) {
      if (event.revision <= listing.revision &&
          event.node?.parentId == parentId) {
        if (event.revision > revision) revision = event.revision;
      } else {
        _event(event);
      }
    }
    _sort();
  }

  void _event(DriveEvent event) {
    _treeBuffer?.add(event);
    if (event.operation == 'ready') {
      live = true;
      notifyListeners();
      return;
    }
    if (_buffer != null) {
      _buffer!.add(event);
      return;
    }
    if (event.revision <= revision) return;
    revision = event.revision;
    final node = event.node;
    if (node != null && event.operation != 'comment') {
      _upsert(node);
      if (selected?.id == node.id) selected = node.deleted ? null : node;
      _sort();
    }
    notifyListeners();
  }

  void _sort() => nodes.sort((a, b) {
    if (a.kind != b.kind) return a.kind == NodeKind.folder ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  void select(FileNode? node) {
    selected = node;
    notifyListeners();
  }

  void reportError(Object failure) {
    error = errorMessage(failure);
    notifyListeners();
  }

  void accept(FileNode node) {
    _upsert(node);
    selected = node;
    notifyListeners();
  }

  void dismissError() {
    error = null;
    notifyListeners();
  }

  Future<void> enter(FileNode folder) => openFolder(folder);

  Future<void> goTo(int depth) {
    if (depth < 0 || depth > path.length) {
      throw ArgumentError.value(depth, 'depth', 'Invalid folder depth.');
    }
    if (depth == path.length) return Future.value();
    return _navigate(path.take(depth).toList());
  }

  Future<void> openFolder(FileNode folder) => _navigate(folders.pathTo(folder));

  Future<void> _navigate(List<FileNode> destination) {
    final parent = destination.isEmpty ? 0 : destination.last.id!;
    if (busy) return Future.value();
    if (folders.isLoaded(parent) && live) {
      path = destination;
      nodes = folders.directory(parent);
      selected = null;
      error = null;
      notifyListeners();
      return Future.value();
    }
    return _request(() async {
      final previous = path;
      final previousNodes = nodes;
      path = destination;
      nodes = [];
      selected = null;
      notifyListeners();
      try {
        await _load();
      } catch (_) {
        path = previous;
        nodes = previousNodes;
        rethrow;
      }
    });
  }

  Future<void> loadFolderChildren(int folderId) async {
    if (folders.isLoaded(folderId) && live) return;
    await _request(() async {
      final generation = _generation;
      _treeBuffer = [];
      try {
        final listing = await gateway.list(drive!.id, folderId);
        if (generation != _generation) return;
        folders.replaceDirectory(folderId, listing.nodes);
        for (final event in _treeBuffer!) {
          if (event.revision > listing.revision &&
              event.node != null &&
              event.operation != 'comment') {
            folders.update(event.node!);
          }
        }
      } finally {
        _treeBuffer = null;
      }
    });
  }

  void _subscribe(int id, int cursor) {
    final generation = _generation;
    _subscription = gateway
        .watch(id, cursor)
        .listen(
          (event) {
            if (generation == _generation) _event(event);
          },
          onError: (Object failure) {
            if (generation != _generation) return;
            live = false;
            folders.invalidate();
            error = errorMessage(failure);
            notifyListeners();
          },
          onDone: () {
            if (generation != _generation) return;
            live = false;
            folders.invalidate();
            notifyListeners();
          },
        );
  }

  Future<void> reconnect() async {
    if (busy || drive == null) return;
    await _subscription?.cancel();
    live = false;
    error = null;
    notifyListeners();
    _subscribe(drive!.id, revision);
  }

  Future<void> create(String name, NodeKind kind) => _request(() async {
    final node = await gateway.create(drive!.id, parentId, name, kind);
    _upsert(node);
    if (kind == NodeKind.folder) folders.markEmpty(node.id!);
    selected = node;
  });
  Future<void> move(FileNode node, int destination, String name) =>
      _request(() async {
        _upsert(await gateway.move(node.id!, destination, name));
      });
  Future<void> delete(FileNode node) => _request(() async {
    await gateway.delete(node.id!);
    folders.remove(node.id!);
    nodes = nodes.where((item) => item.id != node.id).toList();
    selected = null;
  });
  void _acceptImported(int driveId, FileNode node) {
    final index = drive?.id == driveId ? folders : _sessions[driveId]?.folders;
    index?.update(node);
    if (node.kind == NodeKind.folder && !node.deleted) {
      index?.markEmpty(node.id!);
    }
    if (drive?.id == driveId) _upsert(node);
    notifyListeners();
  }

  void _upsert(FileNode node) {
    folders.update(node);
    nodes = nodes.where((item) => item.id != node.id).toList();
    if (!node.deleted && node.parentId == parentId) nodes.add(node);
    _sort();
  }

  Future<void> _request(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      progress = null;
      notifyListeners();
    }
  }

  Future<void> close() async {
    await imports.cancelAndWait();
    _sessions.clear();
    await _detach();
  }

  Future<void> _detach() async {
    _generation++;
    await _subscription?.cancel();
    _subscription = null;
    drive = null;
    folders = DriveFolderIndex();
    nodes = [];
    path = [];
    selected = null;
    _buffer = null;
    revision = 0;
    live = false;
    error = null;
  }

  @override
  void dispose() {
    _generation++;
    unawaited(_subscription?.cancel());
    imports.dispose();
    super.dispose();
  }
}
