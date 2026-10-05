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
import '../gardens/garden_summary.dart' as _iy5a1gj2;
import '../sharing/drive_invitation.dart' as _iurm25tx;
import '../sharing/drive_member_details.dart' as _id7o5eae;

abstract class DriveManagement
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DriveManagement._({
    required this.drive,
    required this.logicalBytes,
    required this.fileCount,
    required this.folderCount,
    required this.members,
    required this.invitations,
  });

  factory DriveManagement({
    required _iy5a1gj2.GardenSummary drive,
    required int logicalBytes,
    required int fileCount,
    required int folderCount,
    required List<_id7o5eae.DriveMemberDetails> members,
    required List<_iurm25tx.DriveInvitation> invitations,
  }) = _DriveManagementImpl;

  factory DriveManagement.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveManagement(
      drive: _ipujdd36.Protocol().deserialize<_iy5a1gj2.GardenSummary>(
        jsonSerialization['drive'],
      ),
      logicalBytes: jsonSerialization['logicalBytes'] as int,
      fileCount: jsonSerialization['fileCount'] as int,
      folderCount: jsonSerialization['folderCount'] as int,
      members: _ipujdd36.Protocol()
          .deserialize<List<_id7o5eae.DriveMemberDetails>>(
            jsonSerialization['members'],
          ),
      invitations: _ipujdd36.Protocol()
          .deserialize<List<_iurm25tx.DriveInvitation>>(
            jsonSerialization['invitations'],
          ),
    );
  }

  _iy5a1gj2.GardenSummary drive;

  int logicalBytes;

  int fileCount;

  int folderCount;

  List<_id7o5eae.DriveMemberDetails> members;

  List<_iurm25tx.DriveInvitation> invitations;

  /// Returns a shallow copy of this [DriveManagement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DriveManagement copyWith({
    _iy5a1gj2.GardenSummary? drive,
    int? logicalBytes,
    int? fileCount,
    int? folderCount,
    List<_id7o5eae.DriveMemberDetails>? members,
    List<_iurm25tx.DriveInvitation>? invitations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveManagement',
      'drive': drive.toJson(),
      'logicalBytes': logicalBytes,
      'fileCount': fileCount,
      'folderCount': folderCount,
      'members': members.toJson(valueToJson: (v) => v.toJson()),
      'invitations': invitations.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveManagement',
      'drive': drive.toJsonForProtocol(),
      'logicalBytes': logicalBytes,
      'fileCount': fileCount,
      'folderCount': folderCount,
      'members': members.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'invitations': invitations.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DriveManagementImpl extends DriveManagement {
  _DriveManagementImpl({
    required _iy5a1gj2.GardenSummary drive,
    required int logicalBytes,
    required int fileCount,
    required int folderCount,
    required List<_id7o5eae.DriveMemberDetails> members,
    required List<_iurm25tx.DriveInvitation> invitations,
  }) : super._(
         drive: drive,
         logicalBytes: logicalBytes,
         fileCount: fileCount,
         folderCount: folderCount,
         members: members,
         invitations: invitations,
       );

  /// Returns a shallow copy of this [DriveManagement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DriveManagement copyWith({
    _iy5a1gj2.GardenSummary? drive,
    int? logicalBytes,
    int? fileCount,
    int? folderCount,
    List<_id7o5eae.DriveMemberDetails>? members,
    List<_iurm25tx.DriveInvitation>? invitations,
  }) {
    return DriveManagement(
      drive: drive ?? this.drive.copyWith(),
      logicalBytes: logicalBytes ?? this.logicalBytes,
      fileCount: fileCount ?? this.fileCount,
      folderCount: folderCount ?? this.folderCount,
      members: members ?? this.members.map((e0) => e0.copyWith()).toList(),
      invitations:
          invitations ?? this.invitations.map((e0) => e0.copyWith()).toList(),
    );
  }
}
