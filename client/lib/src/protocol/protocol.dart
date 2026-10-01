/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:garden_client/src/protocol/gardens/garden_summary.dart'
    as _iwcj6pye;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'gardens/account_details.dart' as _i4muwn5e;
import 'gardens/garden_exception.dart' as _icsgmcpa;
import 'gardens/garden_member.dart' as _icenu3t8;
import 'gardens/garden_record.dart' as _iwqk3oef;
import 'gardens/garden_summary.dart' as _i5zbrq86;
import 'greetings/greeting.dart' as _izw8z7ou;
export 'gardens/account_details.dart';
export 'gardens/garden_exception.dart';
export 'gardens/garden_member.dart';
export 'gardens/garden_record.dart';
export 'gardens/garden_summary.dart';
export 'greetings/greeting.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i4muwn5e.AccountDetails) {
      return _i4muwn5e.AccountDetails.fromJson(data) as T;
    }
    if (t == _icsgmcpa.GardenException) {
      return _icsgmcpa.GardenException.fromJson(data) as T;
    }
    if (t == _icenu3t8.GardenMember) {
      return _icenu3t8.GardenMember.fromJson(data) as T;
    }
    if (t == _iwqk3oef.GardenRecord) {
      return _iwqk3oef.GardenRecord.fromJson(data) as T;
    }
    if (t == _i5zbrq86.GardenSummary) {
      return _i5zbrq86.GardenSummary.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _isc.getType<_i4muwn5e.AccountDetails?>()) {
      return (data != null ? _i4muwn5e.AccountDetails.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icsgmcpa.GardenException?>()) {
      return (data != null ? _icsgmcpa.GardenException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icenu3t8.GardenMember?>()) {
      return (data != null ? _icenu3t8.GardenMember.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwqk3oef.GardenRecord?>()) {
      return (data != null ? _iwqk3oef.GardenRecord.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5zbrq86.GardenSummary?>()) {
      return (data != null ? _i5zbrq86.GardenSummary.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<_iwcj6pye.GardenSummary>) {
      return (data as List)
              .map((e) => deserialize<_iwcj6pye.GardenSummary>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i4muwn5e.AccountDetails => 'AccountDetails',
      _icsgmcpa.GardenException => 'GardenException',
      _icenu3t8.GardenMember => 'GardenMember',
      _iwqk3oef.GardenRecord => 'GardenRecord',
      _i5zbrq86.GardenSummary => 'GardenSummary',
      _izw8z7ou.Greeting => 'Greeting',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('garden.', '');
    }

    switch (data) {
      case _i4muwn5e.AccountDetails():
        return 'AccountDetails';
      case _icsgmcpa.GardenException():
        return 'GardenException';
      case _icenu3t8.GardenMember():
        return 'GardenMember';
      case _iwqk3oef.GardenRecord():
        return 'GardenRecord';
      case _i5zbrq86.GardenSummary():
        return 'GardenSummary';
      case _izw8z7ou.Greeting():
        return 'Greeting';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccountDetails') {
      return deserialize<_i4muwn5e.AccountDetails>(data['data']);
    }
    if (dataClassName == 'GardenException') {
      return deserialize<_icsgmcpa.GardenException>(data['data']);
    }
    if (dataClassName == 'GardenMember') {
      return deserialize<_icenu3t8.GardenMember>(data['data']);
    }
    if (dataClassName == 'GardenRecord') {
      return deserialize<_iwqk3oef.GardenRecord>(data['data']);
    }
    if (dataClassName == 'GardenSummary') {
      return deserialize<_i5zbrq86.GardenSummary>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('garden', this);
    _iacc.Protocol().registerHostProtocol('garden', this);
  }

  @override
  String getModuleName() => 'garden';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
