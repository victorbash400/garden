import 'dart:convert';
import '../generated/protocol.dart';
import 'filesystem_paths.dart';

class FilesystemAttributes {
  static const maximumBytes = 256 * 1024;

  static void validate(FilesystemRequest request) {
    final operation = request.operation;
    final metadata = operation == FilesystemOperation.setAttributes;
    final creation =
        operation == FilesystemOperation.createFile ||
        operation == FilesystemOperation.createFolder;
    final extended =
        operation == FilesystemOperation.setExtendedAttribute ||
        operation == FilesystemOperation.removeExtendedAttribute;
    if ((!metadata &&
            (request.createdAt != null || request.modifiedAt != null)) ||
        (!metadata && !creation && request.attributes != null) ||
        (!extended &&
            (request.attributeName != null ||
                request.attributeValue != null ||
                request.attributeFlags != 0))) {
      FilesystemPaths.fail(
        FilesystemError.invalid,
        'Unexpected attribute arguments.',
      );
    }
    if (metadata || creation) {
      final attributes = request.attributes;
      if ((metadata &&
              request.createdAt == null &&
              request.modifiedAt == null &&
              attributes == null) ||
          attributes?.extended != null ||
          (creation &&
              (attributes?.accessedAt != null || attributes?.flags != null))) {
        FilesystemPaths.fail(
          FilesystemError.invalid,
          'Missing or invalid file attributes.',
        );
      }
      for (final date in [
        request.createdAt,
        request.modifiedAt,
        attributes?.accessedAt,
      ]) {
        if (date != null && (date.year < 1970 || date.year > 9999)) {
          FilesystemPaths.fail(FilesystemError.invalid, 'Invalid file date.');
        }
      }
      final permissions = attributes?.permissions;
      final flags = attributes?.flags;
      if ((permissions != null && (permissions < 0 || permissions > 0x1ff)) ||
          (flags != null && (flags < 0 || flags & ~0x8001 != 0))) {
        FilesystemPaths.fail(
          FilesystemError.invalid,
          'Unsupported file permissions or flags.',
        );
      }
    }
    if (extended) {
      final name = request.attributeName;
      if (name == null ||
          name.isEmpty ||
          utf8.encode(name).length > 255 ||
          name.contains('\u0000')) {
        FilesystemPaths.fail(
          FilesystemError.invalid,
          'Invalid extended attribute name.',
        );
      }
      if (operation == FilesystemOperation.setExtendedAttribute) {
        if (request.attributeValue == null ||
            ![0, 2, 4].contains(request.attributeFlags)) {
          FilesystemPaths.fail(
            FilesystemError.invalid,
            'Invalid extended attribute value or flags.',
          );
        }
        bytes(request.attributeValue!);
      } else if (request.attributeValue != null ||
          request.attributeFlags != 0) {
        FilesystemPaths.fail(
          FilesystemError.invalid,
          'Unexpected remove-attribute arguments.',
        );
      }
    }
  }

  static int bytes(String value) {
    if (value.length > (maximumBytes + 2) ~/ 3 * 4) {
      FilesystemPaths.fail(
        FilesystemError.tooLarge,
        'Extended attributes exceed 256 KiB.',
      );
    }
    try {
      final data = base64Decode(value);
      if (base64Encode(data) != value) {
        FilesystemPaths.fail(
          FilesystemError.invalid,
          'Invalid extended attribute encoding.',
        );
      }
      return data.length;
    } on FormatException {
      FilesystemPaths.fail(
        FilesystemError.invalid,
        'Invalid extended attribute encoding.',
      );
    }
  }

  static bool apply(FileNode node, FilesystemRequest request) {
    final before = jsonEncode(node.toJson());
    final attributes = node.attributes ?? FileAttributes();
    if (request.operation == FilesystemOperation.setAttributes) {
      if (request.createdAt != null) {
        node.createdAt = request.createdAt!.toUtc();
      }
      if (request.modifiedAt != null) {
        node.updatedAt = request.modifiedAt!.toUtc();
      }
      final change = request.attributes;
      if (change != null) {
        attributes.accessedAt =
            change.accessedAt?.toUtc() ?? attributes.accessedAt;
        attributes.permissions = change.permissions ?? attributes.permissions;
        attributes.flags = change.flags ?? attributes.flags;
        node.attributes = attributes;
      }
    } else {
      final values = Map<String, String>.of(attributes.extended ?? {});
      final name = request.attributeName!;
      final present = values.containsKey(name);
      if (request.operation == FilesystemOperation.removeExtendedAttribute ||
          request.attributeFlags == 4) {
        if (!present) {
          FilesystemPaths.fail(
            FilesystemError.noAttribute,
            'Extended attribute does not exist.',
          );
        }
      } else if (request.attributeFlags == 2 && present) {
        FilesystemPaths.fail(
          FilesystemError.alreadyExists,
          'Extended attribute already exists.',
        );
      }
      if (request.operation == FilesystemOperation.removeExtendedAttribute) {
        values.remove(name);
      } else {
        values[name] = request.attributeValue!;
      }
      if (values.length > 64 ||
          values.entries.fold<int>(
                0,
                (total, entry) =>
                    total + utf8.encode(entry.key).length + bytes(entry.value),
              ) >
              maximumBytes) {
        FilesystemPaths.fail(
          FilesystemError.tooLarge,
          'Extended attributes exceed 256 KiB.',
        );
      }
      attributes.extended = values;
      node.attributes = attributes;
    }
    return before != jsonEncode(node.toJson());
  }
}
