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

abstract class PublicIdentity
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PublicIdentity._({
    required this.userId,
    required this.username,
  });

  factory PublicIdentity({
    required String userId,
    required String username,
  }) = _PublicIdentityImpl;

  factory PublicIdentity.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublicIdentity(
      userId: jsonSerialization['userId'] as String,
      username: jsonSerialization['username'] as String,
    );
  }

  String userId;

  String username;

  /// Returns a shallow copy of this [PublicIdentity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PublicIdentity copyWith({
    String? userId,
    String? username,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublicIdentity',
      'userId': userId,
      'username': username,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PublicIdentity',
      'userId': userId,
      'username': username,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PublicIdentityImpl extends PublicIdentity {
  _PublicIdentityImpl({
    required String userId,
    required String username,
  }) : super._(
         userId: userId,
         username: username,
       );

  /// Returns a shallow copy of this [PublicIdentity]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PublicIdentity copyWith({
    String? userId,
    String? username,
  }) {
    return PublicIdentity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}
