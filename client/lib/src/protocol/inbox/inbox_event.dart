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

abstract class InboxEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InboxEvent._({
    this.id,
    required this.userId,
    required this.gardenId,
    this.conversationId,
    required this.kind,
    required this.createdAt,
  });

  factory InboxEvent({
    int? id,
    required String userId,
    required int gardenId,
    int? conversationId,
    required String kind,
    required DateTime createdAt,
  }) = _InboxEventImpl;

  factory InboxEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return InboxEvent(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      gardenId: jsonSerialization['gardenId'] as int,
      conversationId: jsonSerialization['conversationId'] as int?,
      kind: jsonSerialization['kind'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  int gardenId;

  int? conversationId;

  String kind;

  DateTime createdAt;

  /// Returns a shallow copy of this [InboxEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InboxEvent copyWith({
    int? id,
    String? userId,
    int? gardenId,
    int? conversationId,
    String? kind,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InboxEvent',
      if (id != null) 'id': id,
      'userId': userId,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'kind': kind,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InboxEvent',
      if (id != null) 'id': id,
      'userId': userId,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'kind': kind,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InboxEventImpl extends InboxEvent {
  _InboxEventImpl({
    int? id,
    required String userId,
    required int gardenId,
    int? conversationId,
    required String kind,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         gardenId: gardenId,
         conversationId: conversationId,
         kind: kind,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InboxEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InboxEvent copyWith({
    Object? id = _Undefined,
    String? userId,
    int? gardenId,
    Object? conversationId = _Undefined,
    String? kind,
    DateTime? createdAt,
  }) {
    return InboxEvent(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      gardenId: gardenId ?? this.gardenId,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
