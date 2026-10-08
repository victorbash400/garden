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
import 'dart:typed_data' as _idt;
import 'package:garden_client/src/protocol/accounts/public_identity.dart'
    as _ish1qmwt;
import 'package:garden_client/src/protocol/chat/drive_message.dart'
    as _i7cpab2u;
import 'package:garden_client/src/protocol/conversations/conversation_summary.dart'
    as _ivtfh1ba;
import 'package:garden_client/src/protocol/files/drive_event.dart' as _ib0wfils;
import 'package:garden_client/src/protocol/files/file_comment.dart'
    as _i6rexlqc;
import 'package:garden_client/src/protocol/files/file_node.dart' as _i2qlj4hx;
import 'package:garden_client/src/protocol/files/file_version.dart'
    as _ibt6e7l6;
import 'package:garden_client/src/protocol/files/uploaded_part.dart'
    as _ieod4w9g;
import 'package:garden_client/src/protocol/gardens/garden_member.dart'
    as _izuigwd2;
import 'package:garden_client/src/protocol/gardens/garden_summary.dart'
    as _iwcj6pye;
import 'package:garden_client/src/protocol/sharing/account_notification.dart'
    as _ijqj61ga;
import 'package:garden_client/src/protocol/sharing/drive_invitation.dart'
    as _i9n4hrh3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'accounts/account_deletion.dart' as _i9vi6htv;
import 'accounts/account_username.dart' as _iltvw8yc;
import 'accounts/public_identity.dart' as _i70ifst1;
import 'chat/chat_read.dart' as _i3atmsok;
import 'chat/chat_snapshot.dart' as _idocpjhp;
import 'chat/drive_message.dart' as _i2rvmy1x;
import 'conversations/conversation.dart' as _i5m0ut6e;
import 'conversations/conversation_member.dart' as _i1li1n6g;
import 'conversations/conversation_summary.dart' as _igvs8us8;
import 'files/content_download.dart' as _id6mrfn8;
import 'files/directory_listing.dart' as _i8kiawn9;
import 'files/drive_event.dart' as _i4wn0cbe;
import 'files/file_attributes.dart' as _ir46o6qz;
import 'files/file_chunk.dart' as _imjz65yx;
import 'files/file_comment.dart' as _i8jjzct9;
import 'files/file_lease.dart' as _ifu05pz5;
import 'files/file_node.dart' as _iqxechne;
import 'files/file_version.dart' as _inq2edz5;
import 'files/filesystem_error.dart' as _i0zf8lre;
import 'files/filesystem_exception.dart' as _i97gk0ac;
import 'files/filesystem_operation.dart' as _ioqlevl0;
import 'files/filesystem_receipt.dart' as _iorf3lk3;
import 'files/filesystem_request.dart' as _irlkgwt0;
import 'files/node_kind.dart' as _idxfoob7;
import 'files/uploaded_part.dart' as _ivsra0vz;
import 'gardens/account_details.dart' as _i4muwn5e;
import 'gardens/finder_session.dart' as _i14hlkad;
import 'gardens/garden_exception.dart' as _icsgmcpa;
import 'gardens/garden_member.dart' as _icenu3t8;
import 'gardens/garden_record.dart' as _iwqk3oef;
import 'gardens/garden_summary.dart' as _i5zbrq86;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'inbox/inbox_entry.dart' as _ic7xu85a;
import 'inbox/inbox_event.dart' as _ihabtcf0;
import 'inbox/inbox_snapshot.dart' as _ikwold7q;
import 'sharing/account_notification.dart' as _i8nfb11w;
import 'sharing/drive_invitation.dart' as _iks3nfjn;
import 'sharing/drive_management.dart' as _ihkyi9jp;
import 'sharing/drive_member_details.dart' as _iwfm68rt;
export 'accounts/account_deletion.dart';
export 'accounts/account_username.dart';
export 'accounts/public_identity.dart';
export 'chat/chat_read.dart';
export 'chat/chat_snapshot.dart';
export 'chat/drive_message.dart';
export 'conversations/conversation.dart';
export 'conversations/conversation_member.dart';
export 'conversations/conversation_summary.dart';
export 'files/content_download.dart';
export 'files/directory_listing.dart';
export 'files/drive_event.dart';
export 'files/file_attributes.dart';
export 'files/file_chunk.dart';
export 'files/file_comment.dart';
export 'files/file_lease.dart';
export 'files/file_node.dart';
export 'files/file_version.dart';
export 'files/filesystem_error.dart';
export 'files/filesystem_exception.dart';
export 'files/filesystem_operation.dart';
export 'files/filesystem_receipt.dart';
export 'files/filesystem_request.dart';
export 'files/node_kind.dart';
export 'files/uploaded_part.dart';
export 'gardens/account_details.dart';
export 'gardens/finder_session.dart';
export 'gardens/garden_exception.dart';
export 'gardens/garden_member.dart';
export 'gardens/garden_record.dart';
export 'gardens/garden_summary.dart';
export 'greetings/greeting.dart';
export 'inbox/inbox_entry.dart';
export 'inbox/inbox_event.dart';
export 'inbox/inbox_snapshot.dart';
export 'sharing/account_notification.dart';
export 'sharing/drive_invitation.dart';
export 'sharing/drive_management.dart';
export 'sharing/drive_member_details.dart';
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

    if (t == _i9vi6htv.AccountDeletion) {
      return _i9vi6htv.AccountDeletion.fromJson(data) as T;
    }
    if (t == _iltvw8yc.AccountUsername) {
      return _iltvw8yc.AccountUsername.fromJson(data) as T;
    }
    if (t == _i70ifst1.PublicIdentity) {
      return _i70ifst1.PublicIdentity.fromJson(data) as T;
    }
    if (t == _i3atmsok.ChatRead) {
      return _i3atmsok.ChatRead.fromJson(data) as T;
    }
    if (t == _idocpjhp.ChatSnapshot) {
      return _idocpjhp.ChatSnapshot.fromJson(data) as T;
    }
    if (t == _i2rvmy1x.DriveMessage) {
      return _i2rvmy1x.DriveMessage.fromJson(data) as T;
    }
    if (t == _i5m0ut6e.Conversation) {
      return _i5m0ut6e.Conversation.fromJson(data) as T;
    }
    if (t == _i1li1n6g.ConversationMember) {
      return _i1li1n6g.ConversationMember.fromJson(data) as T;
    }
    if (t == _igvs8us8.ConversationSummary) {
      return _igvs8us8.ConversationSummary.fromJson(data) as T;
    }
    if (t == _id6mrfn8.ContentDownload) {
      return _id6mrfn8.ContentDownload.fromJson(data) as T;
    }
    if (t == _i8kiawn9.DirectoryListing) {
      return _i8kiawn9.DirectoryListing.fromJson(data) as T;
    }
    if (t == _i4wn0cbe.DriveEvent) {
      return _i4wn0cbe.DriveEvent.fromJson(data) as T;
    }
    if (t == _ir46o6qz.FileAttributes) {
      return _ir46o6qz.FileAttributes.fromJson(data) as T;
    }
    if (t == _imjz65yx.FileChunk) {
      return _imjz65yx.FileChunk.fromJson(data) as T;
    }
    if (t == _i8jjzct9.FileComment) {
      return _i8jjzct9.FileComment.fromJson(data) as T;
    }
    if (t == _ifu05pz5.FileLease) {
      return _ifu05pz5.FileLease.fromJson(data) as T;
    }
    if (t == _iqxechne.FileNode) {
      return _iqxechne.FileNode.fromJson(data) as T;
    }
    if (t == _inq2edz5.FileVersion) {
      return _inq2edz5.FileVersion.fromJson(data) as T;
    }
    if (t == _i0zf8lre.FilesystemError) {
      return _i0zf8lre.FilesystemError.fromJson(data) as T;
    }
    if (t == _i97gk0ac.FilesystemException) {
      return _i97gk0ac.FilesystemException.fromJson(data) as T;
    }
    if (t == _ioqlevl0.FilesystemOperation) {
      return _ioqlevl0.FilesystemOperation.fromJson(data) as T;
    }
    if (t == _iorf3lk3.FilesystemReceipt) {
      return _iorf3lk3.FilesystemReceipt.fromJson(data) as T;
    }
    if (t == _irlkgwt0.FilesystemRequest) {
      return _irlkgwt0.FilesystemRequest.fromJson(data) as T;
    }
    if (t == _idxfoob7.NodeKind) {
      return _idxfoob7.NodeKind.fromJson(data) as T;
    }
    if (t == _ivsra0vz.UploadedPart) {
      return _ivsra0vz.UploadedPart.fromJson(data) as T;
    }
    if (t == _i4muwn5e.AccountDetails) {
      return _i4muwn5e.AccountDetails.fromJson(data) as T;
    }
    if (t == _i14hlkad.FinderSession) {
      return _i14hlkad.FinderSession.fromJson(data) as T;
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
    if (t == _ic7xu85a.InboxEntry) {
      return _ic7xu85a.InboxEntry.fromJson(data) as T;
    }
    if (t == _ihabtcf0.InboxEvent) {
      return _ihabtcf0.InboxEvent.fromJson(data) as T;
    }
    if (t == _ikwold7q.InboxSnapshot) {
      return _ikwold7q.InboxSnapshot.fromJson(data) as T;
    }
    if (t == _i8nfb11w.AccountNotification) {
      return _i8nfb11w.AccountNotification.fromJson(data) as T;
    }
    if (t == _iks3nfjn.DriveInvitation) {
      return _iks3nfjn.DriveInvitation.fromJson(data) as T;
    }
    if (t == _ihkyi9jp.DriveManagement) {
      return _ihkyi9jp.DriveManagement.fromJson(data) as T;
    }
    if (t == _iwfm68rt.DriveMemberDetails) {
      return _iwfm68rt.DriveMemberDetails.fromJson(data) as T;
    }
    if (t == _isc.getType<_i9vi6htv.AccountDeletion?>()) {
      return (data != null ? _i9vi6htv.AccountDeletion.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iltvw8yc.AccountUsername?>()) {
      return (data != null ? _iltvw8yc.AccountUsername.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i70ifst1.PublicIdentity?>()) {
      return (data != null ? _i70ifst1.PublicIdentity.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i3atmsok.ChatRead?>()) {
      return (data != null ? _i3atmsok.ChatRead.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_idocpjhp.ChatSnapshot?>()) {
      return (data != null ? _idocpjhp.ChatSnapshot.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i2rvmy1x.DriveMessage?>()) {
      return (data != null ? _i2rvmy1x.DriveMessage.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5m0ut6e.Conversation?>()) {
      return (data != null ? _i5m0ut6e.Conversation.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i1li1n6g.ConversationMember?>()) {
      return (data != null ? _i1li1n6g.ConversationMember.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_igvs8us8.ConversationSummary?>()) {
      return (data != null
              ? _igvs8us8.ConversationSummary.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_id6mrfn8.ContentDownload?>()) {
      return (data != null ? _id6mrfn8.ContentDownload.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8kiawn9.DirectoryListing?>()) {
      return (data != null ? _i8kiawn9.DirectoryListing.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i4wn0cbe.DriveEvent?>()) {
      return (data != null ? _i4wn0cbe.DriveEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ir46o6qz.FileAttributes?>()) {
      return (data != null ? _ir46o6qz.FileAttributes.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imjz65yx.FileChunk?>()) {
      return (data != null ? _imjz65yx.FileChunk.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8jjzct9.FileComment?>()) {
      return (data != null ? _i8jjzct9.FileComment.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ifu05pz5.FileLease?>()) {
      return (data != null ? _ifu05pz5.FileLease.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iqxechne.FileNode?>()) {
      return (data != null ? _iqxechne.FileNode.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_inq2edz5.FileVersion?>()) {
      return (data != null ? _inq2edz5.FileVersion.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i0zf8lre.FilesystemError?>()) {
      return (data != null ? _i0zf8lre.FilesystemError.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i97gk0ac.FilesystemException?>()) {
      return (data != null
              ? _i97gk0ac.FilesystemException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ioqlevl0.FilesystemOperation?>()) {
      return (data != null
              ? _ioqlevl0.FilesystemOperation.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iorf3lk3.FilesystemReceipt?>()) {
      return (data != null ? _iorf3lk3.FilesystemReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_irlkgwt0.FilesystemRequest?>()) {
      return (data != null ? _irlkgwt0.FilesystemRequest.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idxfoob7.NodeKind?>()) {
      return (data != null ? _idxfoob7.NodeKind.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ivsra0vz.UploadedPart?>()) {
      return (data != null ? _ivsra0vz.UploadedPart.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4muwn5e.AccountDetails?>()) {
      return (data != null ? _i4muwn5e.AccountDetails.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i14hlkad.FinderSession?>()) {
      return (data != null ? _i14hlkad.FinderSession.fromJson(data) : null)
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
    if (t == _isc.getType<_ic7xu85a.InboxEntry?>()) {
      return (data != null ? _ic7xu85a.InboxEntry.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ihabtcf0.InboxEvent?>()) {
      return (data != null ? _ihabtcf0.InboxEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikwold7q.InboxSnapshot?>()) {
      return (data != null ? _ikwold7q.InboxSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i8nfb11w.AccountNotification?>()) {
      return (data != null
              ? _i8nfb11w.AccountNotification.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iks3nfjn.DriveInvitation?>()) {
      return (data != null ? _iks3nfjn.DriveInvitation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihkyi9jp.DriveManagement?>()) {
      return (data != null ? _ihkyi9jp.DriveManagement.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwfm68rt.DriveMemberDetails?>()) {
      return (data != null ? _iwfm68rt.DriveMemberDetails.fromJson(data) : null)
          as T;
    }
    if (t == List<_i2rvmy1x.DriveMessage>) {
      return (data as List)
              .map((e) => deserialize<_i2rvmy1x.DriveMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_i70ifst1.PublicIdentity>) {
      return (data as List)
              .map((e) => deserialize<_i70ifst1.PublicIdentity>(e))
              .toList()
          as T;
    }
    if (t == List<_iqxechne.FileNode>) {
      return (data as List)
              .map((e) => deserialize<_iqxechne.FileNode>(e))
              .toList()
          as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == _isc.getType<Map<String, String>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<String>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i4wn0cbe.DriveEvent>) {
      return (data as List)
              .map((e) => deserialize<_i4wn0cbe.DriveEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_ic7xu85a.InboxEntry>) {
      return (data as List)
              .map((e) => deserialize<_ic7xu85a.InboxEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_iwfm68rt.DriveMemberDetails>) {
      return (data as List)
              .map((e) => deserialize<_iwfm68rt.DriveMemberDetails>(e))
              .toList()
          as T;
    }
    if (t == List<_iks3nfjn.DriveInvitation>) {
      return (data as List)
              .map((e) => deserialize<_iks3nfjn.DriveInvitation>(e))
              .toList()
          as T;
    }
    if (t == List<_ish1qmwt.PublicIdentity>) {
      return (data as List)
              .map((e) => deserialize<_ish1qmwt.PublicIdentity>(e))
              .toList()
          as T;
    }
    if (t ==
        List<({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      ({
                        DateTime createdAt,
                        _isc.UuidValue id,
                        _idt.ByteData keyId,
                      })
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _isc
            .getType<
              ({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})
            >()) {
      return (
            createdAt: deserialize<DateTime>(
              ((data as Map)['n'] as Map)['createdAt'],
            ),
            id: deserialize<_isc.UuidValue>(data['n']['id']),
            keyId: deserialize<_idt.ByteData>(data['n']['keyId']),
          )
          as T;
    }
    if (t ==
        _isc
            .getType<
              ({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})
            >()) {
      return (
            createdAt: deserialize<DateTime>(
              ((data as Map)['n'] as Map)['createdAt'],
            ),
            id: deserialize<_isc.UuidValue>(data['n']['id']),
            keyId: deserialize<_idt.ByteData>(data['n']['keyId']),
          )
          as T;
    }
    if (t == _isc.getType<({_idt.ByteData challenge, _isc.UuidValue id})>()) {
      return (
            challenge: deserialize<_idt.ByteData>(
              ((data as Map)['n'] as Map)['challenge'],
            ),
            id: deserialize<_isc.UuidValue>(data['n']['id']),
          )
          as T;
    }
    if (t == List<_i7cpab2u.DriveMessage>) {
      return (data as List)
              .map((e) => deserialize<_i7cpab2u.DriveMessage>(e))
              .toList()
          as T;
    }
    if (t == List<_ivtfh1ba.ConversationSummary>) {
      return (data as List)
              .map((e) => deserialize<_ivtfh1ba.ConversationSummary>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i6rexlqc.FileComment>) {
      return (data as List)
              .map((e) => deserialize<_i6rexlqc.FileComment>(e))
              .toList()
          as T;
    }
    if (t == List<_ieod4w9g.UploadedPart>) {
      return (data as List)
              .map((e) => deserialize<_ieod4w9g.UploadedPart>(e))
              .toList()
          as T;
    }
    if (t == List<_idt.ByteData>) {
      return (data as List).map((e) => deserialize<_idt.ByteData>(e)).toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_ibt6e7l6.FileVersion>) {
      return (data as List)
              .map((e) => deserialize<_ibt6e7l6.FileVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_ib0wfils.DriveEvent>) {
      return (data as List)
              .map((e) => deserialize<_ib0wfils.DriveEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_i2qlj4hx.FileNode>) {
      return (data as List)
              .map((e) => deserialize<_i2qlj4hx.FileNode>(e))
              .toList()
          as T;
    }
    if (t == List<_iwcj6pye.GardenSummary>) {
      return (data as List)
              .map((e) => deserialize<_iwcj6pye.GardenSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i9n4hrh3.DriveInvitation>) {
      return (data as List)
              .map((e) => deserialize<_i9n4hrh3.DriveInvitation>(e))
              .toList()
          as T;
    }
    if (t == List<_izuigwd2.GardenMember>) {
      return (data as List)
              .map((e) => deserialize<_izuigwd2.GardenMember>(e))
              .toList()
          as T;
    }
    if (t == List<_ijqj61ga.AccountNotification>) {
      return (data as List)
              .map((e) => deserialize<_ijqj61ga.AccountNotification>(e))
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
      _i9vi6htv.AccountDeletion => 'AccountDeletion',
      _iltvw8yc.AccountUsername => 'AccountUsername',
      _i70ifst1.PublicIdentity => 'PublicIdentity',
      _i3atmsok.ChatRead => 'ChatRead',
      _idocpjhp.ChatSnapshot => 'ChatSnapshot',
      _i2rvmy1x.DriveMessage => 'DriveMessage',
      _i5m0ut6e.Conversation => 'Conversation',
      _i1li1n6g.ConversationMember => 'ConversationMember',
      _igvs8us8.ConversationSummary => 'ConversationSummary',
      _id6mrfn8.ContentDownload => 'ContentDownload',
      _i8kiawn9.DirectoryListing => 'DirectoryListing',
      _i4wn0cbe.DriveEvent => 'DriveEvent',
      _ir46o6qz.FileAttributes => 'FileAttributes',
      _imjz65yx.FileChunk => 'FileChunk',
      _i8jjzct9.FileComment => 'FileComment',
      _ifu05pz5.FileLease => 'FileLease',
      _iqxechne.FileNode => 'FileNode',
      _inq2edz5.FileVersion => 'FileVersion',
      _i0zf8lre.FilesystemError => 'FilesystemError',
      _i97gk0ac.FilesystemException => 'FilesystemException',
      _ioqlevl0.FilesystemOperation => 'FilesystemOperation',
      _iorf3lk3.FilesystemReceipt => 'FilesystemReceipt',
      _irlkgwt0.FilesystemRequest => 'FilesystemRequest',
      _idxfoob7.NodeKind => 'NodeKind',
      _ivsra0vz.UploadedPart => 'UploadedPart',
      _i4muwn5e.AccountDetails => 'AccountDetails',
      _i14hlkad.FinderSession => 'FinderSession',
      _icsgmcpa.GardenException => 'GardenException',
      _icenu3t8.GardenMember => 'GardenMember',
      _iwqk3oef.GardenRecord => 'GardenRecord',
      _i5zbrq86.GardenSummary => 'GardenSummary',
      _izw8z7ou.Greeting => 'Greeting',
      _ic7xu85a.InboxEntry => 'InboxEntry',
      _ihabtcf0.InboxEvent => 'InboxEvent',
      _ikwold7q.InboxSnapshot => 'InboxSnapshot',
      _i8nfb11w.AccountNotification => 'AccountNotification',
      _iks3nfjn.DriveInvitation => 'DriveInvitation',
      _ihkyi9jp.DriveManagement => 'DriveManagement',
      _iwfm68rt.DriveMemberDetails => 'DriveMemberDetails',
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
      case _i9vi6htv.AccountDeletion():
        return 'AccountDeletion';
      case _iltvw8yc.AccountUsername():
        return 'AccountUsername';
      case _i70ifst1.PublicIdentity():
        return 'PublicIdentity';
      case _i3atmsok.ChatRead():
        return 'ChatRead';
      case _idocpjhp.ChatSnapshot():
        return 'ChatSnapshot';
      case _i2rvmy1x.DriveMessage():
        return 'DriveMessage';
      case _i5m0ut6e.Conversation():
        return 'Conversation';
      case _i1li1n6g.ConversationMember():
        return 'ConversationMember';
      case _igvs8us8.ConversationSummary():
        return 'ConversationSummary';
      case _id6mrfn8.ContentDownload():
        return 'ContentDownload';
      case _i8kiawn9.DirectoryListing():
        return 'DirectoryListing';
      case _i4wn0cbe.DriveEvent():
        return 'DriveEvent';
      case _ir46o6qz.FileAttributes():
        return 'FileAttributes';
      case _imjz65yx.FileChunk():
        return 'FileChunk';
      case _i8jjzct9.FileComment():
        return 'FileComment';
      case _ifu05pz5.FileLease():
        return 'FileLease';
      case _iqxechne.FileNode():
        return 'FileNode';
      case _inq2edz5.FileVersion():
        return 'FileVersion';
      case _i0zf8lre.FilesystemError():
        return 'FilesystemError';
      case _i97gk0ac.FilesystemException():
        return 'FilesystemException';
      case _ioqlevl0.FilesystemOperation():
        return 'FilesystemOperation';
      case _iorf3lk3.FilesystemReceipt():
        return 'FilesystemReceipt';
      case _irlkgwt0.FilesystemRequest():
        return 'FilesystemRequest';
      case _idxfoob7.NodeKind():
        return 'NodeKind';
      case _ivsra0vz.UploadedPart():
        return 'UploadedPart';
      case _i4muwn5e.AccountDetails():
        return 'AccountDetails';
      case _i14hlkad.FinderSession():
        return 'FinderSession';
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
      case _ic7xu85a.InboxEntry():
        return 'InboxEntry';
      case _ihabtcf0.InboxEvent():
        return 'InboxEvent';
      case _ikwold7q.InboxSnapshot():
        return 'InboxSnapshot';
      case _i8nfb11w.AccountNotification():
        return 'AccountNotification';
      case _iks3nfjn.DriveInvitation():
        return 'DriveInvitation';
      case _ihkyi9jp.DriveManagement():
        return 'DriveManagement';
      case _iwfm68rt.DriveMemberDetails():
        return 'DriveMemberDetails';
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
    if (dataClassName == 'AccountDeletion') {
      return deserialize<_i9vi6htv.AccountDeletion>(data['data']);
    }
    if (dataClassName == 'AccountUsername') {
      return deserialize<_iltvw8yc.AccountUsername>(data['data']);
    }
    if (dataClassName == 'PublicIdentity') {
      return deserialize<_i70ifst1.PublicIdentity>(data['data']);
    }
    if (dataClassName == 'ChatRead') {
      return deserialize<_i3atmsok.ChatRead>(data['data']);
    }
    if (dataClassName == 'ChatSnapshot') {
      return deserialize<_idocpjhp.ChatSnapshot>(data['data']);
    }
    if (dataClassName == 'DriveMessage') {
      return deserialize<_i2rvmy1x.DriveMessage>(data['data']);
    }
    if (dataClassName == 'Conversation') {
      return deserialize<_i5m0ut6e.Conversation>(data['data']);
    }
    if (dataClassName == 'ConversationMember') {
      return deserialize<_i1li1n6g.ConversationMember>(data['data']);
    }
    if (dataClassName == 'ConversationSummary') {
      return deserialize<_igvs8us8.ConversationSummary>(data['data']);
    }
    if (dataClassName == 'ContentDownload') {
      return deserialize<_id6mrfn8.ContentDownload>(data['data']);
    }
    if (dataClassName == 'DirectoryListing') {
      return deserialize<_i8kiawn9.DirectoryListing>(data['data']);
    }
    if (dataClassName == 'DriveEvent') {
      return deserialize<_i4wn0cbe.DriveEvent>(data['data']);
    }
    if (dataClassName == 'FileAttributes') {
      return deserialize<_ir46o6qz.FileAttributes>(data['data']);
    }
    if (dataClassName == 'FileChunk') {
      return deserialize<_imjz65yx.FileChunk>(data['data']);
    }
    if (dataClassName == 'FileComment') {
      return deserialize<_i8jjzct9.FileComment>(data['data']);
    }
    if (dataClassName == 'FileLease') {
      return deserialize<_ifu05pz5.FileLease>(data['data']);
    }
    if (dataClassName == 'FileNode') {
      return deserialize<_iqxechne.FileNode>(data['data']);
    }
    if (dataClassName == 'FileVersion') {
      return deserialize<_inq2edz5.FileVersion>(data['data']);
    }
    if (dataClassName == 'FilesystemError') {
      return deserialize<_i0zf8lre.FilesystemError>(data['data']);
    }
    if (dataClassName == 'FilesystemException') {
      return deserialize<_i97gk0ac.FilesystemException>(data['data']);
    }
    if (dataClassName == 'FilesystemOperation') {
      return deserialize<_ioqlevl0.FilesystemOperation>(data['data']);
    }
    if (dataClassName == 'FilesystemReceipt') {
      return deserialize<_iorf3lk3.FilesystemReceipt>(data['data']);
    }
    if (dataClassName == 'FilesystemRequest') {
      return deserialize<_irlkgwt0.FilesystemRequest>(data['data']);
    }
    if (dataClassName == 'NodeKind') {
      return deserialize<_idxfoob7.NodeKind>(data['data']);
    }
    if (dataClassName == 'UploadedPart') {
      return deserialize<_ivsra0vz.UploadedPart>(data['data']);
    }
    if (dataClassName == 'AccountDetails') {
      return deserialize<_i4muwn5e.AccountDetails>(data['data']);
    }
    if (dataClassName == 'FinderSession') {
      return deserialize<_i14hlkad.FinderSession>(data['data']);
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
    if (dataClassName == 'InboxEntry') {
      return deserialize<_ic7xu85a.InboxEntry>(data['data']);
    }
    if (dataClassName == 'InboxEvent') {
      return deserialize<_ihabtcf0.InboxEvent>(data['data']);
    }
    if (dataClassName == 'InboxSnapshot') {
      return deserialize<_ikwold7q.InboxSnapshot>(data['data']);
    }
    if (dataClassName == 'AccountNotification') {
      return deserialize<_i8nfb11w.AccountNotification>(data['data']);
    }
    if (dataClassName == 'DriveInvitation') {
      return deserialize<_iks3nfjn.DriveInvitation>(data['data']);
    }
    if (dataClassName == 'DriveManagement') {
      return deserialize<_ihkyi9jp.DriveManagement>(data['data']);
    }
    if (dataClassName == 'DriveMemberDetails') {
      return deserialize<_iwfm68rt.DriveMemberDetails>(data['data']);
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
    if (record
        is ({DateTime createdAt, _isc.UuidValue id, _idt.ByteData keyId})) {
      return {
        "n": {
          "createdAt": record.createdAt.toJson(),
          "id": record.id.toJson(),
          "keyId": record.keyId.toJson(),
        },
      };
    }
    if (record is ({_idt.ByteData challenge, _isc.UuidValue id})) {
      return {
        "n": {
          "challenge": record.challenge.toJson(),
          "id": record.id.toJson(),
        },
      };
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}
