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

abstract class UploadedPart
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UploadedPart._({
    required this.number,
    required this.size,
    required this.checksum,
  });

  factory UploadedPart({
    required int number,
    required int size,
    required String checksum,
  }) = _UploadedPartImpl;

  factory UploadedPart.fromJson(Map<String, dynamic> jsonSerialization) {
    return UploadedPart(
      number: jsonSerialization['number'] as int,
      size: jsonSerialization['size'] as int,
      checksum: jsonSerialization['checksum'] as String,
    );
  }

  int number;

  int size;

  String checksum;

  /// Returns a shallow copy of this [UploadedPart]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UploadedPart copyWith({
    int? number,
    int? size,
    String? checksum,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UploadedPart',
      'number': number,
      'size': size,
      'checksum': checksum,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UploadedPart',
      'number': number,
      'size': size,
      'checksum': checksum,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UploadedPartImpl extends UploadedPart {
  _UploadedPartImpl({
    required int number,
    required int size,
    required String checksum,
  }) : super._(
         number: number,
         size: size,
         checksum: checksum,
       );

  /// Returns a shallow copy of this [UploadedPart]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UploadedPart copyWith({
    int? number,
    int? size,
    String? checksum,
  }) {
    return UploadedPart(
      number: number ?? this.number,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
    );
  }
}
