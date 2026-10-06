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

abstract class AccountNotification
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountNotification._({
    this.id,
    required this.recipientEmail,
    this.gardenId,
    this.conversationId,
    this.invitationId,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.readAt,
    this.trashedAt,
  });

  factory AccountNotification({
    int? id,
    required String recipientEmail,
    int? gardenId,
    int? conversationId,
    int? invitationId,
    required String kind,
    required String title,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  }) = _AccountNotificationImpl;

  factory AccountNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountNotification(
      id: jsonSerialization['id'] as int?,
      recipientEmail: jsonSerialization['recipientEmail'] as String,
      gardenId: jsonSerialization['gardenId'] as int?,
      conversationId: jsonSerialization['conversationId'] as int?,
      invitationId: jsonSerialization['invitationId'] as int?,
      kind: jsonSerialization['kind'] as String,
      title: jsonSerialization['title'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      trashedAt: jsonSerialization['trashedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['trashedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String recipientEmail;

  int? gardenId;

  int? conversationId;

  int? invitationId;

  String kind;

  String title;

  DateTime createdAt;

  DateTime? readAt;

  DateTime? trashedAt;

  /// Returns a shallow copy of this [AccountNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountNotification copyWith({
    int? id,
    String? recipientEmail,
    int? gardenId,
    int? conversationId,
    int? invitationId,
    String? kind,
    String? title,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountNotification',
      if (id != null) 'id': id,
      'recipientEmail': recipientEmail,
      if (gardenId != null) 'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      if (invitationId != null) 'invitationId': invitationId,
      'kind': kind,
      'title': title,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
      if (trashedAt != null) 'trashedAt': trashedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountNotification',
      if (id != null) 'id': id,
      'recipientEmail': recipientEmail,
      if (gardenId != null) 'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      if (invitationId != null) 'invitationId': invitationId,
      'kind': kind,
      'title': title,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
      if (trashedAt != null) 'trashedAt': trashedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountNotificationImpl extends AccountNotification {
  _AccountNotificationImpl({
    int? id,
    required String recipientEmail,
    int? gardenId,
    int? conversationId,
    int? invitationId,
    required String kind,
    required String title,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  }) : super._(
         id: id,
         recipientEmail: recipientEmail,
         gardenId: gardenId,
         conversationId: conversationId,
         invitationId: invitationId,
         kind: kind,
         title: title,
         createdAt: createdAt,
         readAt: readAt,
         trashedAt: trashedAt,
       );

  /// Returns a shallow copy of this [AccountNotification]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountNotification copyWith({
    Object? id = _Undefined,
    String? recipientEmail,
    Object? gardenId = _Undefined,
    Object? conversationId = _Undefined,
    Object? invitationId = _Undefined,
    String? kind,
    String? title,
    DateTime? createdAt,
    Object? readAt = _Undefined,
    Object? trashedAt = _Undefined,
  }) {
    return AccountNotification(
      id: id is int? ? id : this.id,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      gardenId: gardenId is int? ? gardenId : this.gardenId,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      invitationId: invitationId is int? ? invitationId : this.invitationId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      trashedAt: trashedAt is DateTime? ? trashedAt : this.trashedAt,
    );
  }
}
