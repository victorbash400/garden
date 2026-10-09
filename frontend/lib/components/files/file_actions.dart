import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:garden_client/garden_client.dart';

import '../../state/files_controller.dart';
import '../../state/file_editor_controller.dart';
import '../../services/files/file_transfer.dart';
import '../../services/files/import_entry.dart';
import '../../services/files/text_file_type.dart';
import 'file_editor_dialog.dart';
import 'file_move_dialog.dart';
import 'node_name_dialog.dart';

class FileActions {
  const FileActions(this.context, this.controller);
  final BuildContext context;
  final FilesController controller;

  Future<void> create(String kind, {int? parentId}) async {
    if (!controller.canWrite) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => NodeNameDialog(
        action: 'Create',
        value: kind == 'file' ? 'Untitled.txt' : '',
      ),
    );
    if (name != null) {
      await controller.create(
        name,
        kind == 'folder' ? NodeKind.folder : NodeKind.file,
        parentId: parentId,
      );
    }
  }

  Future<void> import({int? parentId}) async {
    if (!controller.canWrite) return;
    final driveId = controller.drive!.id;
    final destination = parentId ?? controller.parentId;
    try {
      final files = await openFiles();
      if (files.isEmpty) return;
      final entries = <ImportEntry>[];
      for (final file in files) {
        entries.add(ImportFile(file.name, await file.length(), file.openRead));
      }
      await controller.imports.import(driveId, destination, entries);
    } catch (failure) {
      controller.reportError(failure);
    }
  }

  Future<void> open(FileNode node) async {
    if (node.kind == NodeKind.folder) {
      await controller.enter(node);
      return;
    }
    final opener = controller.openFile;
    if (opener == null) {
      controller.reportError(StateError('Native file opening is unavailable.'));
      return;
    }
    try {
      await controller.opening.run(node, () => opener(node));
    } catch (failure) {
      controller.reportOpeningError(node, failure);
    }
  }

  Future<void> edit(FileNode node) async {
    if (!controller.canWrite) return;
    if (!isTextFile(node.name)) {
      controller.reportError(StateError('This file cannot be edited as text.'));
      return;
    }
    final saved = await showDialog<FileNode>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FileEditorDialog(
        controller: FileEditorController(controller.gateway, node),
      ),
    );
    if (saved != null) controller.accept(saved);
  }

  Future<void> export(FileNode node, {FileVersion? version}) async {
    try {
      final location = await getSaveLocation(suggestedName: node.name);
      if (location == null) return;
      final sink = File(location.path).openWrite();
      try {
        await sink.addStream(
          FileTransfer(controller.gateway).download(node, version: version),
        );
      } finally {
        await sink.close();
      }
    } catch (failure) {
      controller.reportError(failure);
    }
  }

  Future<void> perform(FileNode node, String action) async {
    if (action.startsWith('openWith:')) {
      final opener = controller.openFileWith;
      if (opener == null) {
        controller.reportError(
          StateError('Choosing an application is unavailable.'),
        );
        return;
      }
      try {
        await controller.opening.run(
          node,
          () => opener(node, action.substring(9)),
        );
      } on PlatformException catch (failure) {
        if (failure.code != 'file_open_cancelled') {
          controller.reportOpeningError(node, failure);
        }
      } catch (failure) {
        controller.reportOpeningError(node, failure);
      }
      return;
    }
    if (controller.busy &&
        !const {'open', 'preview', 'export', 'share'}.contains(action)) {
      controller.reportError(
        StateError(
          'A drive change is still in progress. Try again when it finishes.',
        ),
      );
      return;
    }
    if (!controller.canWrite &&
        const {'edit', 'rename', 'move', 'delete'}.contains(action)) {
      return;
    }
    switch (action) {
      case 'share':
        await controller.shareNode?.call(node);
      case 'open':
        await open(node);
      case 'preview':
        if (node.kind != NodeKind.file) return;
        try {
          final preview = controller.previewFile;
          if (preview == null) {
            throw StateError('Native file previews are unavailable.');
          }
          await controller.opening.run(node, () => preview(node));
        } catch (failure) {
          controller.reportOpeningError(node, failure);
        }
      case 'edit':
        await edit(node);
      case 'export':
        await export(node);
      case 'rename':
        final name = await showDialog<String>(
          context: context,
          builder: (_) => NodeNameDialog(action: 'Rename', value: node.name),
        );
        if (name != null) await controller.move(node, node.parentId, name);
      case 'move':
        final destination = await showDialog<int>(
          context: context,
          builder: (_) =>
              FileMoveDialog(gateway: controller.gateway, node: node),
        );
        if (destination != null) {
          await controller.move(node, destination, node.name);
        }
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Delete ${node.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        if (confirmed == true) await controller.delete(node);
    }
  }
}
