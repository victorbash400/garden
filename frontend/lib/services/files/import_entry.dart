import 'dart:io';

sealed class ImportEntry {
  const ImportEntry(this.name);
  final String name;

  static Future<ImportEntry> fromPath(String path) async {
    final type = await FileSystemEntity.type(path, followLinks: false);
    final name = File(path).uri.pathSegments
        .where((part) => part.isNotEmpty)
        .last;
    if (type == FileSystemEntityType.file) {
      final file = File(path);
      return ImportFile(name, await file.length(), file.openRead);
    }
    if (type == FileSystemEntityType.directory) {
      Stream<ImportEntry> children() async* {
        await for (final item in Directory(path).list(followLinks: false)) {
          yield await fromPath(item.path);
        }
      }

      return ImportDirectory(name, children);
    }
    throw FileSystemException(
      'Only regular files and folders can be imported.',
      path,
    );
  }
}

class ImportFile extends ImportEntry {
  const ImportFile(super.name, this.size, this.read);
  final int size;
  final Stream<List<int>> Function() read;
}

class ImportDirectory extends ImportEntry {
  const ImportDirectory(super.name, this.children);
  final Stream<ImportEntry> Function() children;
}
