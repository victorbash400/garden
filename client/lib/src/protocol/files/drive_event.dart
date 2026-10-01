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
import 'package:garden_client/src/protocol/protocol.dart' as _iyvihoc1;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../files/file_node.dart' as _iylbd4h6;

abstract class DriveEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DriveEvent._({
    this.id,
    required this.gardenId,
    required this.revision,
    required this.operation,
    required this.authorId,
    this.node,
    required this.createdAt,
  });

  factory DriveEvent({
    int? id,
    required int gardenId,
    required int revision,
    required String operation,
    required String authorId,
    _iylbd4h6.FileNode? node,
    required DateTime createdAt,
  }) = _DriveEventImpl;

  factory DriveEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveEvent(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      revision: jsonSerialization['revision'] as int,
      operation: jsonSerialization['operation'] as String,
      authorId: jsonSerialization['authorId'] as String,
      node: jsonSerialization['node'] == null
          ? null
          : _iyvihoc1.Protocol().deserialize<_iylbd4h6.FileNode>(
              jsonSerialization['node'],
            ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int gardenId;

  int revision;

  String operation;

  String authorId;

  _iylbd4h6.FileNode? node;

  DateTime createdAt;

  /// Returns a shallow copy of this [DriveEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DriveEvent copyWith({
    int? id,
    int? gardenId,
    int? revision,
    String? operation,
    String? authorId,
    _iylbd4h6.FileNode? node,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveEvent',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'revision': revision,
      'operation': operation,
      'authorId': authorId,
      if (node != null) 'node': node?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveEvent',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'revision': revision,
      'operation': operation,
      'authorId': authorId,
      if (node != null) 'node': node?.toJsonForProtocol(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveEventImpl extends DriveEvent {
  _DriveEventImpl({
    int? id,
    required int gardenId,
    required int revision,
    required String operation,
    required String authorId,
    _iylbd4h6.FileNode? node,
    required DateTime createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         revision: revision,
         operation: operation,
         authorId: authorId,
         node: node,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DriveEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DriveEvent copyWith({
    Object? id = _Undefined,
    int? gardenId,
    int? revision,
    String? operation,
    String? authorId,
    Object? node = _Undefined,
    DateTime? createdAt,
  }) {
    return DriveEvent(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      revision: revision ?? this.revision,
      operation: operation ?? this.operation,
      authorId: authorId ?? this.authorId,
      node: node is _iylbd4h6.FileNode? ? node : this.node?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
