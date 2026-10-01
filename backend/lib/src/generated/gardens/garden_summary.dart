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
import 'package:serverpod/serverpod.dart' as _is;

abstract class GardenSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  GardenSummary._({
    required this.id,
    required this.name,
    required this.role,
    required this.members,
    this.invitationCode,
  });

  factory GardenSummary({
    required int id,
    required String name,
    required String role,
    required int members,
    String? invitationCode,
  }) = _GardenSummaryImpl;

  factory GardenSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return GardenSummary(
      id: jsonSerialization['id'] as int,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      members: jsonSerialization['members'] as int,
      invitationCode: jsonSerialization['invitationCode'] as String?,
    );
  }

  int id;

  String name;

  String role;

  int members;

  String? invitationCode;

  /// Returns a shallow copy of this [GardenSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GardenSummary copyWith({
    int? id,
    String? name,
    String? role,
    int? members,
    String? invitationCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GardenSummary',
      'id': id,
      'name': name,
      'role': role,
      'members': members,
      if (invitationCode != null) 'invitationCode': invitationCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GardenSummary',
      'id': id,
      'name': name,
      'role': role,
      'members': members,
      if (invitationCode != null) 'invitationCode': invitationCode,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GardenSummaryImpl extends GardenSummary {
  _GardenSummaryImpl({
    required int id,
    required String name,
    required String role,
    required int members,
    String? invitationCode,
  }) : super._(
         id: id,
         name: name,
         role: role,
         members: members,
         invitationCode: invitationCode,
       );

  /// Returns a shallow copy of this [GardenSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GardenSummary copyWith({
    int? id,
    String? name,
    String? role,
    int? members,
    Object? invitationCode = _Undefined,
  }) {
    return GardenSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      members: members ?? this.members,
      invitationCode: invitationCode is String?
          ? invitationCode
          : this.invitationCode,
    );
  }
}
