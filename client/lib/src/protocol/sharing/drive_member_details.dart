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

abstract class DriveMemberDetails
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DriveMemberDetails._({
    required this.userId,
    required this.role,
    required this.displayName,
    this.email,
  });

  factory DriveMemberDetails({
    required String userId,
    required String role,
    required String displayName,
    String? email,
  }) = _DriveMemberDetailsImpl;

  factory DriveMemberDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveMemberDetails(
      userId: jsonSerialization['userId'] as String,
      role: jsonSerialization['role'] as String,
      displayName: jsonSerialization['displayName'] as String,
      email: jsonSerialization['email'] as String?,
    );
  }

  String userId;

  String role;

  String displayName;

  String? email;

  /// Returns a shallow copy of this [DriveMemberDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DriveMemberDetails copyWith({
    String? userId,
    String? role,
    String? displayName,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveMemberDetails',
      'userId': userId,
      'role': role,
      'displayName': displayName,
      if (email != null) 'email': email,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveMemberDetails',
      'userId': userId,
      'role': role,
      'displayName': displayName,
      if (email != null) 'email': email,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveMemberDetailsImpl extends DriveMemberDetails {
  _DriveMemberDetailsImpl({
    required String userId,
    required String role,
    required String displayName,
    String? email,
  }) : super._(
         userId: userId,
         role: role,
         displayName: displayName,
         email: email,
       );

  /// Returns a shallow copy of this [DriveMemberDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DriveMemberDetails copyWith({
    String? userId,
    String? role,
    String? displayName,
    Object? email = _Undefined,
  }) {
    return DriveMemberDetails(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      email: email is String? ? email : this.email,
    );
  }
}
