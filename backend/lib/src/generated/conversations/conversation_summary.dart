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
import '../conversations/conversation.dart' as _ikxk9fze;

abstract class ConversationSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ConversationSummary._({
    required this.conversation,
    required this.members,
  });

  factory ConversationSummary({
    required _ikxk9fze.Conversation conversation,
    required List<_ie9nqzet.PublicIdentity> members,
  }) = _ConversationSummaryImpl;

  factory ConversationSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return ConversationSummary(
      conversation: _ipujdd36.Protocol().deserialize<_ikxk9fze.Conversation>(
        jsonSerialization['conversation'],
      ),
      members: _ipujdd36.Protocol().deserialize<List<_ie9nqzet.PublicIdentity>>(
        jsonSerialization['members'],
      ),
    );
  }

  _ikxk9fze.Conversation conversation;

  List<_ie9nqzet.PublicIdentity> members;

  /// Returns a shallow copy of this [ConversationSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ConversationSummary copyWith({
    _ikxk9fze.Conversation? conversation,
    List<_ie9nqzet.PublicIdentity>? members,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ConversationSummary',
      'conversation': conversation.toJson(),
      'members': members.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ConversationSummary',
      'conversation': conversation.toJsonForProtocol(),
      'members': members.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ConversationSummaryImpl extends ConversationSummary {
  _ConversationSummaryImpl({
    required _ikxk9fze.Conversation conversation,
    required List<_ie9nqzet.PublicIdentity> members,
  }) : super._(
         conversation: conversation,
         members: members,
       );

  /// Returns a shallow copy of this [ConversationSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ConversationSummary copyWith({
    _ikxk9fze.Conversation? conversation,
    List<_ie9nqzet.PublicIdentity>? members,
  }) {
    return ConversationSummary(
      conversation: conversation ?? this.conversation.copyWith(),
      members: members ?? this.members.map((e0) => e0.copyWith()).toList(),
    );
  }
}
