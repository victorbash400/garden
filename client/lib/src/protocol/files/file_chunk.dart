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

abstract class FileChunk
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FileChunk._({
    this.id,
    required this.versionId,
    required this.chunkIndex,
    required this.size,
    required this.checksum,
  });

  factory FileChunk({
    int? id,
    required int versionId,
    required int chunkIndex,
    required int size,
    required String checksum,
  }) = _FileChunkImpl;

  factory FileChunk.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileChunk(
      id: jsonSerialization['id'] as int?,
      versionId: jsonSerialization['versionId'] as int,
      chunkIndex: jsonSerialization['chunkIndex'] as int,
      size: jsonSerialization['size'] as int,
      checksum: jsonSerialization['checksum'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int versionId;

  int chunkIndex;

  int size;

  String checksum;

  /// Returns a shallow copy of this [FileChunk]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FileChunk copyWith({
    int? id,
    int? versionId,
    int? chunkIndex,
    int? size,
    String? checksum,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileChunk',
      if (id != null) 'id': id,
      'versionId': versionId,
      'chunkIndex': chunkIndex,
      'size': size,
      'checksum': checksum,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileChunk',
      if (id != null) 'id': id,
      'versionId': versionId,
      'chunkIndex': chunkIndex,
      'size': size,
      'checksum': checksum,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileChunkImpl extends FileChunk {
  _FileChunkImpl({
    int? id,
    required int versionId,
    required int chunkIndex,
    required int size,
    required String checksum,
  }) : super._(
         id: id,
         versionId: versionId,
         chunkIndex: chunkIndex,
         size: size,
         checksum: checksum,
       );

  /// Returns a shallow copy of this [FileChunk]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FileChunk copyWith({
    Object? id = _Undefined,
    int? versionId,
    int? chunkIndex,
    int? size,
    String? checksum,
  }) {
    return FileChunk(
      id: id is int? ? id : this.id,
      versionId: versionId ?? this.versionId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
    );
  }
}
