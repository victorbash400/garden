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
import '../inbox/inbox_entry.dart' as _iyexrqg4;

abstract class InboxSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  InboxSnapshot._({
    required this.entries,
    required this.cursor,
  });

  factory InboxSnapshot({
    required List<_iyexrqg4.InboxEntry> entries,
    required int cursor,
  }) = _InboxSnapshotImpl;

  factory InboxSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return InboxSnapshot(
      entries: _iyvihoc1.Protocol().deserialize<List<_iyexrqg4.InboxEntry>>(
        jsonSerialization['entries'],
      ),
      cursor: jsonSerialization['cursor'] as int,
    );
  }

  List<_iyexrqg4.InboxEntry> entries;

  int cursor;

  /// Returns a shallow copy of this [InboxSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  InboxSnapshot copyWith({
    List<_iyexrqg4.InboxEntry>? entries,
    int? cursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InboxSnapshot',
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InboxSnapshot',
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _InboxSnapshotImpl extends InboxSnapshot {
  _InboxSnapshotImpl({
    required List<_iyexrqg4.InboxEntry> entries,
    required int cursor,
  }) : super._(
         entries: entries,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [InboxSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  InboxSnapshot copyWith({
    List<_iyexrqg4.InboxEntry>? entries,
    int? cursor,
  }) {
    return InboxSnapshot(
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      cursor: cursor ?? this.cursor,
    );
  }
}
