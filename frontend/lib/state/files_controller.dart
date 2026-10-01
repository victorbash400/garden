import 'dart:async';

import '../utils/error_message.dart';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../model/garden_info.dart';
import '../services/files/files_gateway.dart';
import '../services/files/file_transfer.dart';

class FilesController extends ChangeNotifier {
  FilesController(this.gateway);
  final FilesGateway gateway;
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
  int _generation = 0;
  int get parentId => path.isEmpty ? 0 : path.last.id!;

  Future<void> open(GardenInfo garden) async {
    await close();
    drive = garden;
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
    revision = listing.revision;
    selected = null;
    final events = _buffer!;
    _buffer = null;
    for (final event in events) {
      _event(event);
    }
    _sort();
  }

  void _event(DriveEvent event) {
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

  Future<void> enter(FileNode folder) => _request(() async {
    final previous = path;
    path = [...path, folder];
    try {
      await _load();
    } catch (_) {
      path = previous;
      rethrow;
    }
  });
  Future<void> goTo(int depth) => _request(() async {
    final previous = path;
    path = path.take(depth).toList();
    try {
      await _load();
    } catch (_) {
      path = previous;
      rethrow;
    }
  });
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
            error = errorMessage(failure);
            notifyListeners();
          },
          onDone: () {
            if (generation != _generation) return;
            live = false;
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
    selected = node;
  });
  Future<void> move(FileNode node, int destination, String name) =>
      _request(() async {
        _upsert(await gateway.move(node.id!, destination, name));
      });
  Future<void> delete(FileNode node) => _request(() async {
    await gateway.delete(node.id!);
    nodes = nodes.where((item) => item.id != node.id).toList();
    selected = null;
  });
  Future<void> import(String name, int size, Stream<List<int>> bytes) =>
      _request(() async {
        final node = await gateway.create(
          drive!.id,
          parentId,
          name,
          NodeKind.file,
        );
        _upsert(node);
        final saved = await FileTransfer(gateway).upload(
          node,
          size,
          bytes,
          onProgress: (sent) {
            progress = size == 0 ? 1 : sent / size;
            notifyListeners();
          },
        );
        _upsert(saved);
        selected = saved;
      });
  void _upsert(FileNode node) {
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
    _generation++;
    await _subscription?.cancel();
    _subscription = null;
    drive = null;
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
    super.dispose();
  }
}
