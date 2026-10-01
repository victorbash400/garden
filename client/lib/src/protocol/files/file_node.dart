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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../files/node_kind.dart' as _iiiid2sw;

abstract class FileNode
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FileNode._({
    this.id,
    required this.gardenId,
    required this.parentId,
    required this.name,
    this.activeName,
    required this.kind,
    int? size,
    int? version,
    bool? deleted,
    required this.updatedAt,
  }) : size = size ?? 0,
       version = version ?? 0,
       deleted = deleted ?? false;

  factory FileNode({
    int? id,
    required int gardenId,
    required int parentId,
    required String name,
    String? activeName,
    required _iiiid2sw.NodeKind kind,
    int? size,
    int? version,
    bool? deleted,
    required DateTime updatedAt,
  }) = _FileNodeImpl;

  factory FileNode.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileNode(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      parentId: jsonSerialization['parentId'] as int,
      name: jsonSerialization['name'] as String,
      activeName: jsonSerialization['activeName'] as String?,
      kind: _iiiid2sw.NodeKind.fromJson((jsonSerialization['kind'] as String)),
      size: jsonSerialization['size'] as int?,
      version: jsonSerialization['version'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      updatedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int gardenId;

  int parentId;

  String name;

  String? activeName;

  _iiiid2sw.NodeKind kind;

  int size;

  int version;

  bool deleted;

  DateTime updatedAt;

  /// Returns a shallow copy of this [FileNode]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FileNode copyWith({
    int? id,
    int? gardenId,
    int? parentId,
    String? name,
    String? activeName,
    _iiiid2sw.NodeKind? kind,
    int? size,
    int? version,
    bool? deleted,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileNode',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'parentId': parentId,
      'name': name,
      if (activeName != null) 'activeName': activeName,
      'kind': kind.toJson(),
      'size': size,
      'version': version,
      'deleted': deleted,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileNode',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'parentId': parentId,
      'name': name,
      if (activeName != null) 'activeName': activeName,
      'kind': kind.toJson(),
      'size': size,
      'version': version,
      'deleted': deleted,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileNodeImpl extends FileNode {
  _FileNodeImpl({
    int? id,
    required int gardenId,
    required int parentId,
    required String name,
    String? activeName,
    required _iiiid2sw.NodeKind kind,
    int? size,
    int? version,
    bool? deleted,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         parentId: parentId,
         name: name,
         activeName: activeName,
         kind: kind,
         size: size,
         version: version,
         deleted: deleted,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FileNode]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FileNode copyWith({
    Object? id = _Undefined,
    int? gardenId,
    int? parentId,
    String? name,
    Object? activeName = _Undefined,
    _iiiid2sw.NodeKind? kind,
    int? size,
    int? version,
    bool? deleted,
    DateTime? updatedAt,
  }) {
    return FileNode(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      activeName: activeName is String? ? activeName : this.activeName,
      kind: kind ?? this.kind,
      size: size ?? this.size,
      version: version ?? this.version,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
