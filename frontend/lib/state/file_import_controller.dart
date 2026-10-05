import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../services/files/files_gateway.dart';
import '../services/files/file_transfer.dart';
import '../services/files/import_entry.dart';
import '../services/files/transfer_cancellation.dart';
import '../utils/error_message.dart';

class FileImportController extends ChangeNotifier {
  FileImportController(this.gateway, this.onNode);
  final FilesGateway gateway;
  final void Function(int, FileNode) onNode;
  TransferCancellation? _cancellation;
  Completer<void>? _completion;
  int? driveId;
  bool busy = false;
  bool paused = false;
  bool committing = false;
  String? name;
  String? error;
  String? result;
  double? progress;
  int completed = 0;
  int _foldersCreated = 0;
  String get _importedCount {
    final count = completed + _foldersCreated;
    return "$count ${count == 1 ? 'item' : 'items'} imported";
  }

  bool get canCancel =>
      busy && !committing && _cancellation?.cancelled == false;

  void cancel() {
    if (!canCancel) return;
    _cancellation!.cancel();
    notifyListeners();
  }

  Future<void> cancelAndWait() async {
    cancel();
    await _completion?.future;
  }

  void dismiss() {
    if (busy) return;
    error = null;
    result = null;
    notifyListeners();
  }

  Future<void> import(
    int driveId,
    int parentId,
    List<ImportEntry> entries,
  ) async {
    if (paused) throw StateError('Garden is relaunching.');
    if (busy) throw StateError('An import is already running.');
    busy = true;
    this.driveId = driveId;
    _completion = Completer<void>();
    completed = 0;
    _foldersCreated = 0;
    error = null;
    result = null;
    final cancellation = TransferCancellation();
    _cancellation = cancellation;
    notifyListeners();
    try {
      for (final entry in entries) {
        await _entry(driveId, parentId, entry, cancellation);
      }
      result = _importedCount;
    } on TransferCancelled {
      result = 'Import cancelled · $_importedCount';
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      busy = false;
      committing = false;
      progress = null;
      name = null;
      _cancellation = null;
      this.driveId = null;
      _completion!.complete();
      _completion = null;
      notifyListeners();
    }
  }

  Future<void> _entry(
    int driveId,
    int parentId,
    ImportEntry entry,
    TransferCancellation cancellation,
  ) async {
    cancellation.check();
    name = entry.name;
    progress = null;
    committing = false;
    notifyListeners();
    if (entry is ImportDirectory) {
      final folder = await gateway.create(
        driveId,
        parentId,
        entry.name,
        NodeKind.folder,
      );
      _foldersCreated++;
      onNode(driveId, folder);
      await for (final child in entry.children()) {
        cancellation.check();
        await _entry(driveId, folder.id!, child, cancellation);
      }
      cancellation.check();
      return;
    }
    final file = entry as ImportFile;
    final node = await gateway.create(
      driveId,
      parentId,
      file.name,
      NodeKind.file,
    );
    onNode(driveId, node);
    var commitStarted = false;
    try {
      final saved = await FileTransfer(gateway).upload(
        node,
        file.size,
        file.read(),
        cancellation: cancellation,
        onProgress: (sent) {
          progress = file.size == 0 ? 1 : sent / file.size;
          notifyListeners();
        },
        onCommit: () {
          commitStarted = true;
          committing = true;
          notifyListeners();
        },
      );
      completed++;
      onNode(driveId, saved);
    } catch (failure) {
      if (commitStarted) {
        throw StateError(
          '${errorMessage(failure)} Import completion could not be confirmed. The file was kept.',
        );
      }
      try {
        await gateway.delete(node.id!);
        onNode(driveId, node.copyWith(deleted: true));
      } catch (cleanupFailure) {
        throw StateError(
          '${errorMessage(failure)} Failed to remove incomplete file: ${errorMessage(cleanupFailure)}',
        );
      }
      rethrow;
    }
  }
}
