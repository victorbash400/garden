/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:garden_server/src/generated/protocol.dart' as _ipujdd36;
import 'package:serverpod/serverpod.dart' as _is;

abstract class FileAttributes
    implements _is.SerializableModel, _is.ProtocolSerialization {
  FileAttributes._({
    this.accessedAt,
    this.permissions,
    this.flags,
    this.extended,
  });

  factory FileAttributes({
    DateTime? accessedAt,
    int? permissions,
    int? flags,
    Map<String, String>? extended,
  }) = _FileAttributesImpl;

  factory FileAttributes.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileAttributes(
      accessedAt: jsonSerialization['accessedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['accessedAt']),
      permissions: jsonSerialization['permissions'] as int?,
      flags: jsonSerialization['flags'] as int?,
      extended: jsonSerialization['extended'] == null
          ? null
          : _ipujdd36.Protocol().deserialize<Map<String, String>>(
              jsonSerialization['extended'],
            ),
    );
  }

  DateTime? accessedAt;

  int? permissions;

  int? flags;

  Map<String, String>? extended;

  /// Returns a shallow copy of this [FileAttributes]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FileAttributes copyWith({
    DateTime? accessedAt,
    int? permissions,
    int? flags,
    Map<String, String>? extended,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileAttributes',
      if (accessedAt != null) 'accessedAt': accessedAt?.toJson(),
      if (permissions != null) 'permissions': permissions,
      if (flags != null) 'flags': flags,
      if (extended != null) 'extended': extended?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileAttributes',
      if (accessedAt != null) 'accessedAt': accessedAt?.toJson(),
      if (permissions != null) 'permissions': permissions,
      if (flags != null) 'flags': flags,
      if (extended != null) 'extended': extended?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileAttributesImpl extends FileAttributes {
  _FileAttributesImpl({
    DateTime? accessedAt,
    int? permissions,
    int? flags,
    Map<String, String>? extended,
  }) : super._(
         accessedAt: accessedAt,
         permissions: permissions,
         flags: flags,
         extended: extended,
       );

  /// Returns a shallow copy of this [FileAttributes]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FileAttributes copyWith({
    Object? accessedAt = _Undefined,
    Object? permissions = _Undefined,
    Object? flags = _Undefined,
    Object? extended = _Undefined,
  }) {
    return FileAttributes(
      accessedAt: accessedAt is DateTime? ? accessedAt : this.accessedAt,
      permissions: permissions is int? ? permissions : this.permissions,
      flags: flags is int? ? flags : this.flags,
      extended: extended is Map<String, String>?
          ? extended
          : this.extended?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
    );
  }
}
