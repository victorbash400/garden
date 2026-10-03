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

abstract class FileVersion
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FileVersion._({
    this.id,
    required this.nodeId,
    required this.authorId,
    required this.baseVersion,
    required this.size,
    required this.chunkCount,
    this.objectPath,
    this.uploadId,
    this.partSize,
    bool? committed,
    bool? aborted,
    required this.createdAt,
  }) : committed = committed ?? false,
       aborted = aborted ?? false;

  factory FileVersion({
    int? id,
    required int nodeId,
    required String authorId,
    required int baseVersion,
    required int size,
    required int chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    required DateTime createdAt,
  }) = _FileVersionImpl;

  factory FileVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileVersion(
      id: jsonSerialization['id'] as int?,
      nodeId: jsonSerialization['nodeId'] as int,
      authorId: jsonSerialization['authorId'] as String,
      baseVersion: jsonSerialization['baseVersion'] as int,
      size: jsonSerialization['size'] as int,
      chunkCount: jsonSerialization['chunkCount'] as int,
      objectPath: jsonSerialization['objectPath'] as String?,
      uploadId: jsonSerialization['uploadId'] as String?,
      partSize: jsonSerialization['partSize'] as int?,
      committed: jsonSerialization['committed'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['committed']),
      aborted: jsonSerialization['aborted'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['aborted']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int nodeId;

  String authorId;

  int baseVersion;

  int size;

  int chunkCount;

  String? objectPath;

  String? uploadId;

  int? partSize;

  bool committed;

  bool aborted;

  DateTime createdAt;

  /// Returns a shallow copy of this [FileVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FileVersion copyWith({
    int? id,
    int? nodeId,
    String? authorId,
    int? baseVersion,
    int? size,
    int? chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileVersion',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'baseVersion': baseVersion,
      'size': size,
      'chunkCount': chunkCount,
      if (objectPath != null) 'objectPath': objectPath,
      if (uploadId != null) 'uploadId': uploadId,
      if (partSize != null) 'partSize': partSize,
      'committed': committed,
      'aborted': aborted,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileVersion',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'baseVersion': baseVersion,
      'size': size,
      'chunkCount': chunkCount,
      if (objectPath != null) 'objectPath': objectPath,
      if (uploadId != null) 'uploadId': uploadId,
      if (partSize != null) 'partSize': partSize,
      'committed': committed,
      'aborted': aborted,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileVersionImpl extends FileVersion {
  _FileVersionImpl({
    int? id,
    required int nodeId,
    required String authorId,
    required int baseVersion,
    required int size,
    required int chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    required DateTime createdAt,
  }) : super._(
         id: id,
         nodeId: nodeId,
         authorId: authorId,
         baseVersion: baseVersion,
         size: size,
         chunkCount: chunkCount,
         objectPath: objectPath,
         uploadId: uploadId,
         partSize: partSize,
         committed: committed,
         aborted: aborted,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FileVersion]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FileVersion copyWith({
    Object? id = _Undefined,
    int? nodeId,
    String? authorId,
    int? baseVersion,
    int? size,
    int? chunkCount,
    Object? objectPath = _Undefined,
    Object? uploadId = _Undefined,
    Object? partSize = _Undefined,
    bool? committed,
    bool? aborted,
    DateTime? createdAt,
  }) {
    return FileVersion(
      id: id is int? ? id : this.id,
      nodeId: nodeId ?? this.nodeId,
      authorId: authorId ?? this.authorId,
      baseVersion: baseVersion ?? this.baseVersion,
      size: size ?? this.size,
      chunkCount: chunkCount ?? this.chunkCount,
      objectPath: objectPath is String? ? objectPath : this.objectPath,
      uploadId: uploadId is String? ? uploadId : this.uploadId,
      partSize: partSize is int? ? partSize : this.partSize,
      committed: committed ?? this.committed,
      aborted: aborted ?? this.aborted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
