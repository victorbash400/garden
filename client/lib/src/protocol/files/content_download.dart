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

abstract class ContentDownload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ContentDownload._({
    this.url,
    required this.size,
    required this.expiresAt,
  });

  factory ContentDownload({
    String? url,
    required int size,
    required DateTime expiresAt,
  }) = _ContentDownloadImpl;

  factory ContentDownload.fromJson(Map<String, dynamic> jsonSerialization) {
    return ContentDownload(
      url: jsonSerialization['url'] as String?,
      size: jsonSerialization['size'] as int,
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String? url;

  int size;

  DateTime expiresAt;

  /// Returns a shallow copy of this [ContentDownload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ContentDownload copyWith({
    String? url,
    int? size,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ContentDownload',
      if (url != null) 'url': url,
      'size': size,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ContentDownload',
      if (url != null) 'url': url,
      'size': size,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContentDownloadImpl extends ContentDownload {
  _ContentDownloadImpl({
    String? url,
    required int size,
    required DateTime expiresAt,
  }) : super._(
         url: url,
         size: size,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [ContentDownload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ContentDownload copyWith({
    Object? url = _Undefined,
    int? size,
    DateTime? expiresAt,
  }) {
    return ContentDownload(
      url: url is String? ? url : this.url,
      size: size ?? this.size,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
