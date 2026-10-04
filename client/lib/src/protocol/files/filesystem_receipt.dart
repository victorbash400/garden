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
import '../files/drive_event.dart' as _inr98x4d;
import '../files/filesystem_request.dart' as _iielzn32;

abstract class FilesystemReceipt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  FilesystemReceipt._({
    this.id,
    required this.gardenId,
    required this.authorId,
    required this.request,
    required this.operationId,
    required this.events,
  });

  factory FilesystemReceipt({
    int? id,
    required int gardenId,
    required String authorId,
    required _iielzn32.FilesystemRequest request,
    required _isc.UuidValue operationId,
    required List<_inr98x4d.DriveEvent> events,
  }) = _FilesystemReceiptImpl;

  factory FilesystemReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return FilesystemReceipt(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      authorId: jsonSerialization['authorId'] as String,
      request: _iyvihoc1.Protocol().deserialize<_iielzn32.FilesystemRequest>(
        jsonSerialization['request'],
      ),
      operationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['operationId'],
      ),
      events: _iyvihoc1.Protocol().deserialize<List<_inr98x4d.DriveEvent>>(
        jsonSerialization['events'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int gardenId;

  String authorId;

  _iielzn32.FilesystemRequest request;

  _isc.UuidValue operationId;

  List<_inr98x4d.DriveEvent> events;

  /// Returns a shallow copy of this [FilesystemReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FilesystemReceipt copyWith({
    int? id,
    int? gardenId,
    String? authorId,
    _iielzn32.FilesystemRequest? request,
    _isc.UuidValue? operationId,
    List<_inr98x4d.DriveEvent>? events,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FilesystemReceipt',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'authorId': authorId,
      'request': request.toJson(),
      'operationId': operationId.toJson(),
      'events': events.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilesystemReceipt',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'authorId': authorId,
      'request': request.toJsonForProtocol(),
      'operationId': operationId.toJson(),
      'events': events.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilesystemReceiptImpl extends FilesystemReceipt {
  _FilesystemReceiptImpl({
    int? id,
    required int gardenId,
    required String authorId,
    required _iielzn32.FilesystemRequest request,
    required _isc.UuidValue operationId,
    required List<_inr98x4d.DriveEvent> events,
  }) : super._(
         id: id,
         gardenId: gardenId,
         authorId: authorId,
         request: request,
         operationId: operationId,
         events: events,
       );

  /// Returns a shallow copy of this [FilesystemReceipt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FilesystemReceipt copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? authorId,
    _iielzn32.FilesystemRequest? request,
    _isc.UuidValue? operationId,
    List<_inr98x4d.DriveEvent>? events,
  }) {
    return FilesystemReceipt(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      authorId: authorId ?? this.authorId,
      request: request ?? this.request.copyWith(),
      operationId: operationId ?? this.operationId,
      events: events ?? this.events.map((e0) => e0.copyWith()).toList(),
    );
  }
}
