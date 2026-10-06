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
import 'package:garden_server/src/generated/protocol.dart' as _ipujdd36;
import 'package:serverpod/serverpod.dart' as _is;
import '../accounts/public_identity.dart' as _ie9nqzet;
import '../chat/drive_message.dart' as _is6wyiq3;

abstract class ChatSnapshot
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ChatSnapshot._({
    required this.messages,
    required this.identities,
    required this.readCursor,
    required this.unreadCount,
    int? latestMessageId,
  }) : latestMessageId = latestMessageId ?? 0;

  factory ChatSnapshot({
    required List<_is6wyiq3.DriveMessage> messages,
    required List<_ie9nqzet.PublicIdentity> identities,
    required int readCursor,
    required int unreadCount,
    int? latestMessageId,
  }) = _ChatSnapshotImpl;

  factory ChatSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSnapshot(
      messages: _ipujdd36.Protocol().deserialize<List<_is6wyiq3.DriveMessage>>(
        jsonSerialization['messages'],
      ),
      identities: _ipujdd36.Protocol()
          .deserialize<List<_ie9nqzet.PublicIdentity>>(
            jsonSerialization['identities'],
          ),
      readCursor: jsonSerialization['readCursor'] as int,
      unreadCount: jsonSerialization['unreadCount'] as int,
      latestMessageId: jsonSerialization['latestMessageId'] as int?,
    );
  }

  List<_is6wyiq3.DriveMessage> messages;

  List<_ie9nqzet.PublicIdentity> identities;

  int readCursor;

  int unreadCount;

  int latestMessageId;

  /// Returns a shallow copy of this [ChatSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChatSnapshot copyWith({
    List<_is6wyiq3.DriveMessage>? messages,
    List<_ie9nqzet.PublicIdentity>? identities,
    int? readCursor,
    int? unreadCount,
    int? latestMessageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSnapshot',
      'messages': messages.toJson(valueToJson: (v) => v.toJson()),
      'identities': identities.toJson(valueToJson: (v) => v.toJson()),
      'readCursor': readCursor,
      'unreadCount': unreadCount,
      'latestMessageId': latestMessageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatSnapshot',
      'messages': messages.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'identities': identities.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'readCursor': readCursor,
      'unreadCount': unreadCount,
      'latestMessageId': latestMessageId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ChatSnapshotImpl extends ChatSnapshot {
  _ChatSnapshotImpl({
    required List<_is6wyiq3.DriveMessage> messages,
    required List<_ie9nqzet.PublicIdentity> identities,
    required int readCursor,
    required int unreadCount,
    int? latestMessageId,
  }) : super._(
         messages: messages,
         identities: identities,
         readCursor: readCursor,
         unreadCount: unreadCount,
         latestMessageId: latestMessageId,
       );

  /// Returns a shallow copy of this [ChatSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChatSnapshot copyWith({
    List<_is6wyiq3.DriveMessage>? messages,
    List<_ie9nqzet.PublicIdentity>? identities,
    int? readCursor,
    int? unreadCount,
    int? latestMessageId,
  }) {
    return ChatSnapshot(
      messages: messages ?? this.messages.map((e0) => e0.copyWith()).toList(),
      identities:
          identities ?? this.identities.map((e0) => e0.copyWith()).toList(),
      readCursor: readCursor ?? this.readCursor,
      unreadCount: unreadCount ?? this.unreadCount,
      latestMessageId: latestMessageId ?? this.latestMessageId,
    );
  }
}
