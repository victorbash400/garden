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

abstract class FileLease
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FileLease._({
    this.id,
    required this.nodeId,
    required this.holderId,
    required this.token,
    required this.expiresAt,
  });

  factory FileLease({
    int? id,
    required int nodeId,
    required String holderId,
    required String token,
    required DateTime expiresAt,
  }) = _FileLeaseImpl;

  factory FileLease.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileLease(
      id: jsonSerialization['id'] as int?,
      nodeId: jsonSerialization['nodeId'] as int,
      holderId: jsonSerialization['holderId'] as String,
      token: jsonSerialization['token'] as String,
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int nodeId;

  String holderId;

  String token;

  DateTime expiresAt;

  /// Returns a shallow copy of this [FileLease]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FileLease copyWith({
    int? id,
    int? nodeId,
    String? holderId,
    String? token,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileLease',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'holderId': holderId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileLease',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'holderId': holderId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileLeaseImpl extends FileLease {
  _FileLeaseImpl({
    int? id,
    required int nodeId,
    required String holderId,
    required String token,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         nodeId: nodeId,
         holderId: holderId,
         token: token,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [FileLease]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FileLease copyWith({
    Object? id = _Undefined,
    int? nodeId,
    String? holderId,
    String? token,
    DateTime? expiresAt,
  }) {
    return FileLease(
      id: id is int? ? id : this.id,
      nodeId: nodeId ?? this.nodeId,
      holderId: holderId ?? this.holderId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
