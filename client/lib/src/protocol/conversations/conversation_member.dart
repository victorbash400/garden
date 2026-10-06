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

abstract class ConversationMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ConversationMember._({
    this.id,
    required this.conversationId,
    required this.userId,
    int? readCursor,
  }) : readCursor = readCursor ?? 0;

  factory ConversationMember({
    int? id,
    required int conversationId,
    required String userId,
    int? readCursor,
  }) = _ConversationMemberImpl;

  factory ConversationMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConversationMember(
      id: jsonSerialization['id'] as int?,
      conversationId: jsonSerialization['conversationId'] as int,
      userId: jsonSerialization['userId'] as String,
      readCursor: jsonSerialization['readCursor'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int conversationId;

  String userId;

  int readCursor;

  /// Returns a shallow copy of this [ConversationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ConversationMember copyWith({
    int? id,
    int? conversationId,
    String? userId,
    int? readCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConversationMember',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'readCursor': readCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConversationMember',
      if (id != null) 'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'readCursor': readCursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConversationMemberImpl extends ConversationMember {
  _ConversationMemberImpl({
    int? id,
    required int conversationId,
    required String userId,
    int? readCursor,
  }) : super._(
         id: id,
         conversationId: conversationId,
         userId: userId,
         readCursor: readCursor,
       );

  /// Returns a shallow copy of this [ConversationMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ConversationMember copyWith({
    Object? id = _Undefined,
    int? conversationId,
    String? userId,
    int? readCursor,
  }) {
    return ConversationMember(
      id: id is int? ? id : this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      readCursor: readCursor ?? this.readCursor,
    );
  }
}
