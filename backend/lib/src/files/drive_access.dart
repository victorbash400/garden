import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class DriveAccess {
  static String user(Session session) => session.authenticated!.userIdentifier;

  static Future<void> require(
    Session session,
    int gardenId, {
    Transaction? transaction,
  }) async {
    final member = await GardenMember.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) & row.userId.equals(user(session)),
      transaction: transaction,
    );
    final drive = await GardenRecord.db.findById(
      session,
      gardenId,
      transaction: transaction,
    );
    if (member == null || drive == null || drive.deleted) {
      throw GardenException(message: 'You do not have access to this drive.');
    }
  }

  static Future<FileNode> node(
    Session session,
    int id, {
    Transaction? transaction,
  }) async {
    final node = await FileNode.db.findById(
      session,
      id,
      transaction: transaction,
    );
    if (node == null || node.deleted) {
      throw GardenException(message: 'This file or folder no longer exists.');
    }
    await require(session, node.gardenId, transaction: transaction);
    return node;
  }

  static Future<FileNode> contentNode(Session session, int id) async {
    final node = await FileNode.db.findById(session, id);
    if (node == null || node.kind != NodeKind.file) {
      throw GardenException(message: 'This file version is unavailable.');
    }
    await require(session, node.gardenId);
    return node;
  }

  static Future<GardenRecord> lock(
    Session session,
    int gardenId,
    Transaction transaction, {
    LockMode mode = LockMode.forUpdate,
  }) async {
    final member = await GardenMember.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(gardenId) & row.userId.equals(user(session)),
      transaction: transaction,
    );
    if (member == null) {
      throw GardenException(message: 'You do not have access to this drive.');
    }
    final drive = await GardenRecord.db.findById(
      session,
      gardenId,
      transaction: transaction,
      lockMode: mode,
    );
    if (drive == null || drive.deleted) {
      throw GardenException(message: 'This drive no longer exists.');
    }
    return drive;
  }

  static Future<void> parent(
    Session session,
    int gardenId,
    int parentId,
    Transaction transaction,
  ) async {
    if (parentId == 0) return;
    final parent = await FileNode.db.findById(
      session,
      parentId,
      transaction: transaction,
    );
    if (parent == null ||
        parent.deleted ||
        parent.gardenId != gardenId ||
        parent.kind != NodeKind.folder) {
      throw GardenException(message: 'Choose a folder in this drive.');
    }
  }

  static String name(String value) {
    final name = value.trim();
    if (name.isEmpty ||
        utf8.encode(name).length > 255 ||
        name == '.' ||
        name == '..' ||
        name.contains('/') ||
        name.contains(':') ||
        name.codeUnits.any((unit) => unit < 32)) {
      throw GardenException(
        message:
            'Use a file name of 1–255 bytes without slashes, colons, or control characters.',
      );
    }
    return name;
  }

  static String conflictName(String name, int versionId, int attempt) {
    final suffix = attempt == 0
        ? ' (conflict $versionId)'
        : ' (conflict $versionId-$attempt)';
    final limit = 255 - utf8.encode(suffix).length;
    final prefix = StringBuffer();
    var length = 0;
    for (final rune in name.runes) {
      final character = String.fromCharCode(rune);
      final size = utf8.encode(character).length;
      if (length + size > limit) break;
      prefix.write(character);
      length += size;
    }
    return '$prefix$suffix';
  }

  static Future<void> available(
    Session session,
    int drive,
    int parent,
    String name,
    Transaction transaction, {
    int? except,
  }) async {
    final existing = await FileNode.db.findFirstRow(
      session,
      where: (row) =>
          row.gardenId.equals(drive) &
          row.parentId.equals(parent) &
          row.activeName.equals(name.toLowerCase()),
      transaction: transaction,
    );
    if (existing != null && existing.id != except) {
      throw GardenException(
        message: 'A file or folder with this name already exists.',
      );
    }
  }
}
