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

abstract class DriveMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DriveMessage._({
    this.id,
    required this.gardenId,
    this.conversationId,
    required this.authorId,
    required this.username,
    required this.text,
    this.replyToId,
    this.nodeId,
    this.nodeName,
    bool? hasReplies,
    required this.createdAt,
  }) : hasReplies = hasReplies ?? false;

  factory DriveMessage({
    int? id,
    required int gardenId,
    int? conversationId,
    required String authorId,
    required String username,
    required String text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    required DateTime createdAt,
  }) = _DriveMessageImpl;

  factory DriveMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveMessage(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      conversationId: jsonSerialization['conversationId'] as int?,
      authorId: jsonSerialization['authorId'] as String,
      username: jsonSerialization['username'] as String,
      text: jsonSerialization['text'] as String,
      replyToId: jsonSerialization['replyToId'] as int?,
      nodeId: jsonSerialization['nodeId'] as int?,
      nodeName: jsonSerialization['nodeName'] as String?,
      hasReplies: jsonSerialization['hasReplies'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['hasReplies']),
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

  int? conversationId;

  String authorId;

  String username;

  String text;

  int? replyToId;

  int? nodeId;

  String? nodeName;

  bool hasReplies;

  DateTime createdAt;

  /// Returns a shallow copy of this [DriveMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DriveMessage copyWith({
    int? id,
    int? gardenId,
    int? conversationId,
    String? authorId,
    String? username,
    String? text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveMessage',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'authorId': authorId,
      'username': username,
      'text': text,
      if (replyToId != null) 'replyToId': replyToId,
      if (nodeId != null) 'nodeId': nodeId,
      if (nodeName != null) 'nodeName': nodeName,
      'hasReplies': hasReplies,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveMessage',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'authorId': authorId,
      'username': username,
      'text': text,
      if (replyToId != null) 'replyToId': replyToId,
      if (nodeId != null) 'nodeId': nodeId,
      if (nodeName != null) 'nodeName': nodeName,
      'hasReplies': hasReplies,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveMessageImpl extends DriveMessage {
  _DriveMessageImpl({
    int? id,
    required int gardenId,
    int? conversationId,
    required String authorId,
    required String username,
    required String text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    required DateTime createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         conversationId: conversationId,
         authorId: authorId,
         username: username,
         text: text,
         replyToId: replyToId,
         nodeId: nodeId,
         nodeName: nodeName,
         hasReplies: hasReplies,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DriveMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DriveMessage copyWith({
    Object? id = _Undefined,
    int? gardenId,
    Object? conversationId = _Undefined,
    String? authorId,
    String? username,
    String? text,
    Object? replyToId = _Undefined,
    Object? nodeId = _Undefined,
    Object? nodeName = _Undefined,
    bool? hasReplies,
    DateTime? createdAt,
  }) {
    return DriveMessage(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      text: text ?? this.text,
      replyToId: replyToId is int? ? replyToId : this.replyToId,
      nodeId: nodeId is int? ? nodeId : this.nodeId,
      nodeName: nodeName is String? ? nodeName : this.nodeName,
      hasReplies: hasReplies ?? this.hasReplies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
