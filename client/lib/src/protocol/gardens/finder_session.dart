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

abstract class FinderSession
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FinderSession._({
    required this.token,
    required this.refreshToken,
    required this.tokenId,
  });

  factory FinderSession({
    required String token,
    required String refreshToken,
    required String tokenId,
  }) = _FinderSessionImpl;

  factory FinderSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return FinderSession(
      token: jsonSerialization['token'] as String,
      refreshToken: jsonSerialization['refreshToken'] as String,
      tokenId: jsonSerialization['tokenId'] as String,
    );
  }

  String token;

  String refreshToken;

  String tokenId;

  /// Returns a shallow copy of this [FinderSession]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FinderSession copyWith({
    String? token,
    String? refreshToken,
    String? tokenId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FinderSession',
      'token': token,
      'refreshToken': refreshToken,
      'tokenId': tokenId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FinderSession',
      'token': token,
      'refreshToken': refreshToken,
      'tokenId': tokenId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _FinderSessionImpl extends FinderSession {
  _FinderSessionImpl({
    required String token,
    required String refreshToken,
    required String tokenId,
  }) : super._(
         token: token,
         refreshToken: refreshToken,
         tokenId: tokenId,
       );

  /// Returns a shallow copy of this [FinderSession]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FinderSession copyWith({
    String? token,
    String? refreshToken,
    String? tokenId,
  }) {
    return FinderSession(
      token: token ?? this.token,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenId: tokenId ?? this.tokenId,
    );
  }
}
