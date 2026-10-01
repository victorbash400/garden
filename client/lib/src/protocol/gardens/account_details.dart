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

abstract class AccountDetails
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AccountDetails._({
    required this.id,
    required this.email,
  });

  factory AccountDetails({
    required String id,
    required String email,
  }) = _AccountDetailsImpl;

  factory AccountDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountDetails(
      id: jsonSerialization['id'] as String,
      email: jsonSerialization['email'] as String,
    );
  }

  String id;

  String email;

  /// Returns a shallow copy of this [AccountDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AccountDetails copyWith({
    String? id,
    String? email,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountDetails',
      'id': id,
      'email': email,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountDetails',
      'id': id,
      'email': email,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AccountDetailsImpl extends AccountDetails {
  _AccountDetailsImpl({
    required String id,
    required String email,
  }) : super._(
         id: id,
         email: email,
       );

  /// Returns a shallow copy of this [AccountDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AccountDetails copyWith({
    String? id,
    String? email,
  }) {
    return AccountDetails(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }
}
