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

abstract class DriveInvitation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DriveInvitation._({
    this.id,
    required this.gardenId,
    required this.inviterId,
    required this.recipientEmail,
    required this.role,
    required this.expiresAt,
    required this.createdAt,
    this.acceptedBy,
    this.acceptedAt,
    this.declinedAt,
    this.revokedAt,
    String? deliveryStatus,
    this.deliveryMessageId,
    this.deliveryError,
  }) : deliveryStatus = deliveryStatus ?? 'notConfigured';

  factory DriveInvitation({
    int? id,
    required int gardenId,
    required String inviterId,
    required String recipientEmail,
    required String role,
    required DateTime expiresAt,
    required DateTime createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  }) = _DriveInvitationImpl;

  factory DriveInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveInvitation(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      inviterId: jsonSerialization['inviterId'] as String,
      recipientEmail: jsonSerialization['recipientEmail'] as String,
      role: jsonSerialization['role'] as String,
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      acceptedBy: jsonSerialization['acceptedBy'] as String?,
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['acceptedAt'],
            ),
      declinedAt: jsonSerialization['declinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['declinedAt'],
            ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      deliveryStatus: jsonSerialization['deliveryStatus'] as String?,
      deliveryMessageId: jsonSerialization['deliveryMessageId'] as String?,
      deliveryError: jsonSerialization['deliveryError'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int gardenId;

  String inviterId;

  String recipientEmail;

  String role;

  DateTime expiresAt;

  DateTime createdAt;

  String? acceptedBy;

  DateTime? acceptedAt;

  DateTime? declinedAt;

  DateTime? revokedAt;

  String deliveryStatus;

  String? deliveryMessageId;

  String? deliveryError;

  /// Returns a shallow copy of this [DriveInvitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DriveInvitation copyWith({
    int? id,
    int? gardenId,
    String? inviterId,
    String? recipientEmail,
    String? role,
    DateTime? expiresAt,
    DateTime? createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveInvitation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'inviterId': inviterId,
      'recipientEmail': recipientEmail,
      'role': role,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (declinedAt != null) 'declinedAt': declinedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'deliveryStatus': deliveryStatus,
      if (deliveryMessageId != null) 'deliveryMessageId': deliveryMessageId,
      if (deliveryError != null) 'deliveryError': deliveryError,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveInvitation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'inviterId': inviterId,
      'recipientEmail': recipientEmail,
      'role': role,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (declinedAt != null) 'declinedAt': declinedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'deliveryStatus': deliveryStatus,
      if (deliveryMessageId != null) 'deliveryMessageId': deliveryMessageId,
      if (deliveryError != null) 'deliveryError': deliveryError,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveInvitationImpl extends DriveInvitation {
  _DriveInvitationImpl({
    int? id,
    required int gardenId,
    required String inviterId,
    required String recipientEmail,
    required String role,
    required DateTime expiresAt,
    required DateTime createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  }) : super._(
         id: id,
         gardenId: gardenId,
         inviterId: inviterId,
         recipientEmail: recipientEmail,
         role: role,
         expiresAt: expiresAt,
         createdAt: createdAt,
         acceptedBy: acceptedBy,
         acceptedAt: acceptedAt,
         declinedAt: declinedAt,
         revokedAt: revokedAt,
         deliveryStatus: deliveryStatus,
         deliveryMessageId: deliveryMessageId,
         deliveryError: deliveryError,
       );

  /// Returns a shallow copy of this [DriveInvitation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DriveInvitation copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? inviterId,
    String? recipientEmail,
    String? role,
    DateTime? expiresAt,
    DateTime? createdAt,
    Object? acceptedBy = _Undefined,
    Object? acceptedAt = _Undefined,
    Object? declinedAt = _Undefined,
    Object? revokedAt = _Undefined,
    String? deliveryStatus,
    Object? deliveryMessageId = _Undefined,
    Object? deliveryError = _Undefined,
  }) {
    return DriveInvitation(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      inviterId: inviterId ?? this.inviterId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      acceptedBy: acceptedBy is String? ? acceptedBy : this.acceptedBy,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      declinedAt: declinedAt is DateTime? ? declinedAt : this.declinedAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryMessageId: deliveryMessageId is String?
          ? deliveryMessageId
          : this.deliveryMessageId,
      deliveryError: deliveryError is String?
          ? deliveryError
          : this.deliveryError,
    );
  }
}
