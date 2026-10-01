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

abstract class FileComment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FileComment._({
    this.id,
    required this.nodeId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory FileComment({
    int? id,
    required int nodeId,
    required String authorId,
    required String text,
    required DateTime createdAt,
  }) = _FileCommentImpl;

  factory FileComment.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileComment(
      id: jsonSerialization['id'] as int?,
      nodeId: jsonSerialization['nodeId'] as int,
      authorId: jsonSerialization['authorId'] as String,
      text: jsonSerialization['text'] as String,
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

  String text;

  DateTime createdAt;

  /// Returns a shallow copy of this [FileComment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FileComment copyWith({
    int? id,
    int? nodeId,
    String? authorId,
    String? text,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileComment',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileComment',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'text': text,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileCommentImpl extends FileComment {
  _FileCommentImpl({
    int? id,
    required int nodeId,
    required String authorId,
    required String text,
    required DateTime createdAt,
  }) : super._(
         id: id,
         nodeId: nodeId,
         authorId: authorId,
         text: text,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FileComment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FileComment copyWith({
    Object? id = _Undefined,
    int? nodeId,
    String? authorId,
    String? text,
    DateTime? createdAt,
  }) {
    return FileComment(
      id: id is int? ? id : this.id,
      nodeId: nodeId ?? this.nodeId,
      authorId: authorId ?? this.authorId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
