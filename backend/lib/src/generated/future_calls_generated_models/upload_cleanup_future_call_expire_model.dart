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

abstract class UploadCleanupFutureCallExpireModel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  UploadCleanupFutureCallExpireModel._({required this.versionId});

  factory UploadCleanupFutureCallExpireModel({required int versionId}) =
      _UploadCleanupFutureCallExpireModelImpl;

  factory UploadCleanupFutureCallExpireModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return UploadCleanupFutureCallExpireModel(
      versionId: jsonSerialization['versionId'] as int,
    );
  }

  int versionId;

  /// Returns a shallow copy of this [UploadCleanupFutureCallExpireModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  UploadCleanupFutureCallExpireModel copyWith({int? versionId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UploadCleanupFutureCallExpireModel',
      'versionId': versionId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UploadCleanupFutureCallExpireModelImpl
    extends UploadCleanupFutureCallExpireModel {
  _UploadCleanupFutureCallExpireModelImpl({required int versionId})
    : super._(versionId: versionId);

  /// Returns a shallow copy of this [UploadCleanupFutureCallExpireModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  UploadCleanupFutureCallExpireModel copyWith({int? versionId}) {
    return UploadCleanupFutureCallExpireModel(
      versionId: versionId ?? this.versionId,
    );
  }
}
