import 'dart:convert';

import '../utils/error_message.dart';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../services/files/file_transfer.dart';
import '../services/files/files_gateway.dart';

class FileEditorController extends ChangeNotifier {
  FileEditorController(this.gateway, this.node);
  final FilesGateway gateway;
  FileNode node;
  String text = '';
  bool busy = false;
  bool loaded = false;
  String? error;

  Future<void> load() => _request(() async {
    if (node.size > 1024 * 1024) {
      throw StateError(
        'The text editor supports files up to 1 MiB. Use Export for larger files.',
      );
    }
    final bytes = await FileTransfer(gateway)
        .download(node)
        .expand((chunk) => chunk)
        .toList();
    text = utf8.decode(bytes);
    loaded = true;
  });

  Future<void> save(String value) => _request(() async {
    final lease = await gateway.acquire(node.id!);
    try {
      final bytes = utf8.encode(value);
      final saved = await FileTransfer(gateway)
          .upload(node, bytes.length, Stream.value(bytes));
      if (saved.id != node.id) {
        error =
            'The file changed elsewhere. Your edits were saved as ${saved.name}.';
      }
      node = saved;
      text = value;
    } finally {
      await gateway.release(lease.nodeId, lease.token);
    }
  });

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
      notifyListeners();
    }
  }
}
