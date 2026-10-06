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

abstract class Conversation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Conversation._({
    this.id,
    required this.gardenId,
    required this.creatorId,
    required this.title,
    this.directKey,
    required this.createdAt,
  });

  factory Conversation({
    int? id,
    required int gardenId,
    required String creatorId,
    required String title,
    String? directKey,
    required DateTime createdAt,
  }) = _ConversationImpl;

  factory Conversation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Conversation(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      creatorId: jsonSerialization['creatorId'] as String,
      title: jsonSerialization['title'] as String,
      directKey: jsonSerialization['directKey'] as String?,
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

  String creatorId;

  String title;

  String? directKey;

  DateTime createdAt;

  /// Returns a shallow copy of this [Conversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Conversation copyWith({
    int? id,
    int? gardenId,
    String? creatorId,
    String? title,
    String? directKey,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Conversation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'creatorId': creatorId,
      'title': title,
      if (directKey != null) 'directKey': directKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Conversation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'creatorId': creatorId,
      'title': title,
      if (directKey != null) 'directKey': directKey,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConversationImpl extends Conversation {
  _ConversationImpl({
    int? id,
    required int gardenId,
    required String creatorId,
    required String title,
    String? directKey,
    required DateTime createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         creatorId: creatorId,
         title: title,
         directKey: directKey,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Conversation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Conversation copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? creatorId,
    String? title,
    Object? directKey = _Undefined,
    DateTime? createdAt,
  }) {
    return Conversation(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      directKey: directKey is String? ? directKey : this.directKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
