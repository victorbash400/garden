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

abstract class ChatRead
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChatRead._({
    this.id,
    required this.gardenId,
    required this.userId,
    required this.messageId,
  });

  factory ChatRead({
    int? id,
    required int gardenId,
    required String userId,
    required int messageId,
  }) = _ChatReadImpl;

  factory ChatRead.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatRead(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      userId: jsonSerialization['userId'] as String,
      messageId: jsonSerialization['messageId'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int gardenId;

  String userId;

  int messageId;

  /// Returns a shallow copy of this [ChatRead]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ChatRead copyWith({
    int? id,
    int? gardenId,
    String? userId,
    int? messageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatRead',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'messageId': messageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatRead',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'messageId': messageId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatReadImpl extends ChatRead {
  _ChatReadImpl({
    int? id,
    required int gardenId,
    required String userId,
    required int messageId,
  }) : super._(
         id: id,
         gardenId: gardenId,
         userId: userId,
         messageId: messageId,
       );

  /// Returns a shallow copy of this [ChatRead]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ChatRead copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? userId,
    int? messageId,
  }) {
    return ChatRead(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      userId: userId ?? this.userId,
      messageId: messageId ?? this.messageId,
    );
  }
}
