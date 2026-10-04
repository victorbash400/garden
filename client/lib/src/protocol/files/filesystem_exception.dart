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
import '../files/filesystem_error.dart' as _i2p3ir3s;

abstract class FilesystemException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  FilesystemException._({
    required this.code,
    required this.message,
  });

  factory FilesystemException({
    required _i2p3ir3s.FilesystemError code,
    required String message,
  }) = _FilesystemExceptionImpl;

  factory FilesystemException.fromJson(Map<String, dynamic> jsonSerialization) {
    return FilesystemException(
      code: _i2p3ir3s.FilesystemError.fromJson(
        (jsonSerialization['code'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _i2p3ir3s.FilesystemError code;

  String message;

  /// Returns a shallow copy of this [FilesystemException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  FilesystemException copyWith({
    _i2p3ir3s.FilesystemError? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FilesystemException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilesystemException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'FilesystemException(code: $code, message: $message)';
  }
}

class _FilesystemExceptionImpl extends FilesystemException {
  _FilesystemExceptionImpl({
    required _i2p3ir3s.FilesystemError code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [FilesystemException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  FilesystemException copyWith({
    _i2p3ir3s.FilesystemError? code,
    String? message,
  }) {
    return FilesystemException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
