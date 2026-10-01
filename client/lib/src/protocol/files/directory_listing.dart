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
import '../files/file_node.dart' as _iylbd4h6;

abstract class DirectoryListing
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DirectoryListing._({
    required this.revision,
    required this.nodes,
  });

  factory DirectoryListing({
    required int revision,
    required List<_iylbd4h6.FileNode> nodes,
  }) = _DirectoryListingImpl;

  factory DirectoryListing.fromJson(Map<String, dynamic> jsonSerialization) {
    return DirectoryListing(
      revision: jsonSerialization['revision'] as int,
      nodes: _iyvihoc1.Protocol().deserialize<List<_iylbd4h6.FileNode>>(
        jsonSerialization['nodes'],
      ),
    );
  }

  int revision;

  List<_iylbd4h6.FileNode> nodes;

  /// Returns a shallow copy of this [DirectoryListing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DirectoryListing copyWith({
    int? revision,
    List<_iylbd4h6.FileNode>? nodes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DirectoryListing',
      'revision': revision,
      'nodes': nodes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DirectoryListing',
      'revision': revision,
      'nodes': nodes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DirectoryListingImpl extends DirectoryListing {
  _DirectoryListingImpl({
    required int revision,
    required List<_iylbd4h6.FileNode> nodes,
  }) : super._(
         revision: revision,
         nodes: nodes,
       );

  /// Returns a shallow copy of this [DirectoryListing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DirectoryListing copyWith({
    int? revision,
    List<_iylbd4h6.FileNode>? nodes,
  }) {
    return DirectoryListing(
      revision: revision ?? this.revision,
      nodes: nodes ?? this.nodes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
