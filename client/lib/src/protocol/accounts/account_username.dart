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

abstract class AccountUsername
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountUsername._({
    this.id,
    required this.userId,
    required this.username,
  });

  factory AccountUsername({
    int? id,
    required String userId,
    required String username,
  }) = _AccountUsernameImpl;

  factory AccountUsername.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountUsername(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      username: jsonSerialization['username'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String userId;

  String username;

  /// Returns a shallow copy of this [AccountUsername]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountUsername copyWith({
    int? id,
    String? userId,
    String? username,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountUsername',
      if (id != null) 'id': id,
      'userId': userId,
      'username': username,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountUsername',
      if (id != null) 'id': id,
      'userId': userId,
      'username': username,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountUsernameImpl extends AccountUsername {
  _AccountUsernameImpl({
    int? id,
    required String userId,
    required String username,
  }) : super._(
         id: id,
         userId: userId,
         username: username,
       );

  /// Returns a shallow copy of this [AccountUsername]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountUsername copyWith({
    Object? id = _Undefined,
    String? userId,
    String? username,
  }) {
    return AccountUsername(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}
