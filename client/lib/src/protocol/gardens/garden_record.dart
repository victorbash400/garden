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

abstract class GardenRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  GardenRecord._({
    this.id,
    required this.name,
    required this.ownerId,
    required this.invitationHash,
    required this.createdAt,
    int? revision,
    bool? deleted,
  }) : revision = revision ?? 0,
       deleted = deleted ?? false;

  factory GardenRecord({
    int? id,
    required String name,
    required String ownerId,
    required String invitationHash,
    required DateTime createdAt,
    int? revision,
    bool? deleted,
  }) = _GardenRecordImpl;

  factory GardenRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return GardenRecord(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      ownerId: jsonSerialization['ownerId'] as String,
      invitationHash: jsonSerialization['invitationHash'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revision: jsonSerialization['revision'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  String ownerId;

  String invitationHash;

  DateTime createdAt;

  int revision;

  bool deleted;

  /// Returns a shallow copy of this [GardenRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  GardenRecord copyWith({
    int? id,
    String? name,
    String? ownerId,
    String? invitationHash,
    DateTime? createdAt,
    int? revision,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GardenRecord',
      if (id != null) 'id': id,
      'name': name,
      'ownerId': ownerId,
      'invitationHash': invitationHash,
      'createdAt': createdAt.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GardenRecord',
      if (id != null) 'id': id,
      'name': name,
      'ownerId': ownerId,
      'invitationHash': invitationHash,
      'createdAt': createdAt.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GardenRecordImpl extends GardenRecord {
  _GardenRecordImpl({
    int? id,
    required String name,
    required String ownerId,
    required String invitationHash,
    required DateTime createdAt,
    int? revision,
    bool? deleted,
  }) : super._(
         id: id,
         name: name,
         ownerId: ownerId,
         invitationHash: invitationHash,
         createdAt: createdAt,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [GardenRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  GardenRecord copyWith({
    Object? id = _Undefined,
    String? name,
    String? ownerId,
    String? invitationHash,
    DateTime? createdAt,
    int? revision,
    bool? deleted,
  }) {
    return GardenRecord(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      invitationHash: invitationHash ?? this.invitationHash,
      createdAt: createdAt ?? this.createdAt,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}
