import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

ClientAuthSuccessStorage localSessionStorage(
  String serverUrl, {
  String windowId = 'main',
  Directory? directory,
}) => KeyValueClientAuthSuccessStorage(
  authSuccessStorageKey: '$serverUrl\u0000$windowId',
  keyValueStorage: LocalSessionFiles(directory: directory),
);

class LocalSessionFiles implements KeyValueStorage {
  LocalSessionFiles({Directory? directory})
    : directory = directory ?? _defaultDirectory();
  final Directory directory;

  static Directory _defaultDirectory() {
    final home = Platform.environment['HOME'];
    if (!Platform.isMacOS || home == null || home.isEmpty) {
      throw UnsupportedError('Local Garden sessions require macOS.');
    }
    return Directory('$home/Library/Application Support/Garden/Sessions');
  }

  Future<File> _file(String key) async {
    await directory.create(recursive: true);
    if (await FileSystemEntity.type(directory.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw StateError('The session directory is invalid.');
    }
    await _permissions(directory.path, '700');
    final name = sha256.convert(utf8.encode(key));
    final file = File('${directory.path}/$name.json');
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw StateError('The saved session is not a regular file.');
    }
    return file;
  }

  Future<void> _permissions(String path, String mode) async {
    final result = await Process.run('/bin/chmod', [mode, path]);
    if (result.exitCode != 0) {
      throw StateError('Could not protect the saved session.');
    }
  }

  @override
  Future<String?> get(String key) async {
    final file = await _file(key);
    if (!await file.exists()) return null;
    await _permissions(file.path, '600');
    return file.readAsString();
  }

  @override
  Future<void> set(String key, String? value) async {
    final file = await _file(key);
    if (value == null) {
      if (await file.exists()) await file.delete();
      return;
    }
    final temporary = File(
      '${file.path}.$pid.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(value, flush: true);
      await _permissions(temporary.path, '600');
      await temporary.rename(file.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }
}
