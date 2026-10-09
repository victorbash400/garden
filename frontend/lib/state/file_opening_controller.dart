import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

class FileOpeningController extends ChangeNotifier {
  FileNode? node;
  String stage = 'Checking drive connection';
  Future<void>? _pending;
  bool _disposed = false;

  Future<void> run(FileNode file, Future<void> Function() action) {
    if (_pending != null) {
      if (node?.gardenId == file.gardenId && node?.id == file.id) {
        return _pending!;
      }
      return Future.error(StateError('Wait for the current file to open.'));
    }
    final completion = Completer<void>();
    _pending = completion.future;
    node = file;
    stage = 'Checking drive connection';
    notifyListeners();
    unawaited(_run(action, completion));
    return completion.future;
  }

  void launching({String? application}) {
    stage = application == null
        ? 'Opening in the default application'
        : 'Opening in $application';
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(
    Future<void> Function() action,
    Completer<void> completion,
  ) async {
    try {
      await action().timeout(const Duration(minutes: 2));
      completion.complete();
    } catch (error, stack) {
      completion.completeError(error, stack);
    } finally {
      node = null;
      _pending = null;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
