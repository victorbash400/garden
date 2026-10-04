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
import 'package:garden_client/src/protocol/protocol.dart' as _iyvihoc1;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../files/file_attributes.dart' as _ikwv8ta6;
import '../files/filesystem_operation.dart' as _i3gax0t1;

abstract class FilesystemRequest
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FilesystemRequest._({
    required this.operationId,
    required this.operation,
    required this.path,
    this.destination,
    bool? noReplace,
    this.createdAt,
    this.modifiedAt,
    this.attributes,
    this.attributeName,
    this.attributeValue,
    int? attributeFlags,
  }) : noReplace = noReplace ?? false,
       attributeFlags = attributeFlags ?? 0;

  factory FilesystemRequest({
    required _isc.UuidValue operationId,
    required _i3gax0t1.FilesystemOperation operation,
    required String path,
    String? destination,
    bool? noReplace,
    DateTime? createdAt,
    DateTime? modifiedAt,
    _ikwv8ta6.FileAttributes? attributes,
    String? attributeName,
    String? attributeValue,
    int? attributeFlags,
  }) = _FilesystemRequestImpl;

  factory FilesystemRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return FilesystemRequest(
      operationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['operationId'],
      ),
      operation: _i3gax0t1.FilesystemOperation.fromJson(
        (jsonSerialization['operation'] as String),
      ),
      path: jsonSerialization['path'] as String,
      destination: jsonSerialization['destination'] as String?,
      noReplace: jsonSerialization['noReplace'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['noReplace']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      modifiedAt: jsonSerialization['modifiedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['modifiedAt'],
            ),
      attributes: jsonSerialization['attributes'] == null
          ? null
          : _iyvihoc1.Protocol().deserialize<_ikwv8ta6.FileAttributes>(
              jsonSerialization['attributes'],
            ),
      attributeName: jsonSerialization['attributeName'] as String?,
      attributeValue: jsonSerialization['attributeValue'] as String?,
      attributeFlags: jsonSerialization['attributeFlags'] as int?,
    );
  }

  _isc.UuidValue operationId;

  _i3gax0t1.FilesystemOperation operation;

  String path;

  String? destination;

  bool noReplace;

  DateTime? createdAt;

  DateTime? modifiedAt;

  _ikwv8ta6.FileAttributes? attributes;

  String? attributeName;

  String? attributeValue;

  int attributeFlags;

  /// Returns a shallow copy of this [FilesystemRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FilesystemRequest copyWith({
    _isc.UuidValue? operationId,
    _i3gax0t1.FilesystemOperation? operation,
    String? path,
    String? destination,
    bool? noReplace,
    DateTime? createdAt,
    DateTime? modifiedAt,
    _ikwv8ta6.FileAttributes? attributes,
    String? attributeName,
    String? attributeValue,
    int? attributeFlags,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FilesystemRequest',
      'operationId': operationId.toJson(),
      'operation': operation.toJson(),
      'path': path,
      if (destination != null) 'destination': destination,
      'noReplace': noReplace,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (modifiedAt != null) 'modifiedAt': modifiedAt?.toJson(),
      if (attributes != null) 'attributes': attributes?.toJson(),
      if (attributeName != null) 'attributeName': attributeName,
      if (attributeValue != null) 'attributeValue': attributeValue,
      'attributeFlags': attributeFlags,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilesystemRequest',
      'operationId': operationId.toJson(),
      'operation': operation.toJson(),
      'path': path,
      if (destination != null) 'destination': destination,
      'noReplace': noReplace,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (modifiedAt != null) 'modifiedAt': modifiedAt?.toJson(),
      if (attributes != null) 'attributes': attributes?.toJsonForProtocol(),
      if (attributeName != null) 'attributeName': attributeName,
      if (attributeValue != null) 'attributeValue': attributeValue,
      'attributeFlags': attributeFlags,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilesystemRequestImpl extends FilesystemRequest {
  _FilesystemRequestImpl({
    required _isc.UuidValue operationId,
    required _i3gax0t1.FilesystemOperation operation,
    required String path,
    String? destination,
    bool? noReplace,
    DateTime? createdAt,
    DateTime? modifiedAt,
    _ikwv8ta6.FileAttributes? attributes,
    String? attributeName,
    String? attributeValue,
    int? attributeFlags,
  }) : super._(
         operationId: operationId,
         operation: operation,
         path: path,
         destination: destination,
         noReplace: noReplace,
         createdAt: createdAt,
         modifiedAt: modifiedAt,
         attributes: attributes,
         attributeName: attributeName,
         attributeValue: attributeValue,
         attributeFlags: attributeFlags,
       );

  /// Returns a shallow copy of this [FilesystemRequest]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FilesystemRequest copyWith({
    _isc.UuidValue? operationId,
    _i3gax0t1.FilesystemOperation? operation,
    String? path,
    Object? destination = _Undefined,
    bool? noReplace,
    Object? createdAt = _Undefined,
    Object? modifiedAt = _Undefined,
    Object? attributes = _Undefined,
    Object? attributeName = _Undefined,
    Object? attributeValue = _Undefined,
    int? attributeFlags,
  }) {
    return FilesystemRequest(
      operationId: operationId ?? this.operationId,
      operation: operation ?? this.operation,
      path: path ?? this.path,
      destination: destination is String? ? destination : this.destination,
      noReplace: noReplace ?? this.noReplace,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      modifiedAt: modifiedAt is DateTime? ? modifiedAt : this.modifiedAt,
      attributes: attributes is _ikwv8ta6.FileAttributes?
          ? attributes
          : this.attributes?.copyWith(),
      attributeName: attributeName is String?
          ? attributeName
          : this.attributeName,
      attributeValue: attributeValue is String?
          ? attributeValue
          : this.attributeValue,
      attributeFlags: attributeFlags ?? this.attributeFlags,
    );
  }
}
