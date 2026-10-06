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
import 'package:garden_server/src/generated/protocol.dart' as _ipujdd36;
import 'package:serverpod/serverpod.dart' as _is;
import '../accounts/public_identity.dart' as _ie9nqzet;

abstract class InboxEntry
    implements _is.SerializableModel, _is.ProtocolSerialization {
  InboxEntry._({
    required this.gardenId,
    required this.driveName,
    this.conversationId,
    required this.title,
    this.createdAt,
    this.creatorId,
    required this.members,
    required this.unreadCount,
    required this.latestText,
    this.latestAt,
    bool? isNew,
  }) : isNew = isNew ?? false;

  factory InboxEntry({
    required int gardenId,
    required String driveName,
    int? conversationId,
    required String title,
    DateTime? createdAt,
    String? creatorId,
    required List<_ie9nqzet.PublicIdentity> members,
    required int unreadCount,
    required String latestText,
    DateTime? latestAt,
    bool? isNew,
  }) = _InboxEntryImpl;

  factory InboxEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return InboxEntry(
      gardenId: jsonSerialization['gardenId'] as int,
      driveName: jsonSerialization['driveName'] as String,
      conversationId: jsonSerialization['conversationId'] as int?,
      title: jsonSerialization['title'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      creatorId: jsonSerialization['creatorId'] as String?,
      members: _ipujdd36.Protocol().deserialize<List<_ie9nqzet.PublicIdentity>>(
        jsonSerialization['members'],
      ),
      unreadCount: jsonSerialization['unreadCount'] as int,
      latestText: jsonSerialization['latestText'] as String,
      latestAt: jsonSerialization['latestAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['latestAt']),
      isNew: jsonSerialization['isNew'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isNew']),
    );
  }

  int gardenId;

  String driveName;

  int? conversationId;

  String title;

  DateTime? createdAt;

  String? creatorId;

  List<_ie9nqzet.PublicIdentity> members;

  int unreadCount;

  String latestText;

  DateTime? latestAt;

  bool isNew;

  /// Returns a shallow copy of this [InboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InboxEntry copyWith({
    int? gardenId,
    String? driveName,
    int? conversationId,
    String? title,
    DateTime? createdAt,
    String? creatorId,
    List<_ie9nqzet.PublicIdentity>? members,
    int? unreadCount,
    String? latestText,
    DateTime? latestAt,
    bool? isNew,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InboxEntry',
      'gardenId': gardenId,
      'driveName': driveName,
      if (conversationId != null) 'conversationId': conversationId,
      'title': title,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (creatorId != null) 'creatorId': creatorId,
      'members': members.toJson(valueToJson: (v) => v.toJson()),
      'unreadCount': unreadCount,
      'latestText': latestText,
      if (latestAt != null) 'latestAt': latestAt?.toJson(),
      'isNew': isNew,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InboxEntry',
      'gardenId': gardenId,
      'driveName': driveName,
      if (conversationId != null) 'conversationId': conversationId,
      'title': title,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (creatorId != null) 'creatorId': creatorId,
      'members': members.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'unreadCount': unreadCount,
      'latestText': latestText,
      if (latestAt != null) 'latestAt': latestAt?.toJson(),
      'isNew': isNew,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InboxEntryImpl extends InboxEntry {
  _InboxEntryImpl({
    required int gardenId,
    required String driveName,
    int? conversationId,
    required String title,
    DateTime? createdAt,
    String? creatorId,
    required List<_ie9nqzet.PublicIdentity> members,
    required int unreadCount,
    required String latestText,
    DateTime? latestAt,
    bool? isNew,
  }) : super._(
         gardenId: gardenId,
         driveName: driveName,
         conversationId: conversationId,
         title: title,
         createdAt: createdAt,
         creatorId: creatorId,
         members: members,
         unreadCount: unreadCount,
         latestText: latestText,
         latestAt: latestAt,
         isNew: isNew,
       );

  /// Returns a shallow copy of this [InboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InboxEntry copyWith({
    int? gardenId,
    String? driveName,
    Object? conversationId = _Undefined,
    String? title,
    Object? createdAt = _Undefined,
    Object? creatorId = _Undefined,
    List<_ie9nqzet.PublicIdentity>? members,
    int? unreadCount,
    String? latestText,
    Object? latestAt = _Undefined,
    bool? isNew,
  }) {
    return InboxEntry(
      gardenId: gardenId ?? this.gardenId,
      driveName: driveName ?? this.driveName,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      title: title ?? this.title,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      creatorId: creatorId is String? ? creatorId : this.creatorId,
      members: members ?? this.members.map((e0) => e0.copyWith()).toList(),
      unreadCount: unreadCount ?? this.unreadCount,
      latestText: latestText ?? this.latestText,
      latestAt: latestAt is DateTime? ? latestAt : this.latestAt,
      isNew: isNew ?? this.isNew,
    );
  }
}
