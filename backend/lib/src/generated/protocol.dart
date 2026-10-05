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
import 'package:garden_server/src/generated/files/drive_event.dart'
    as _ipqwe4ae;
import 'package:garden_server/src/generated/files/file_comment.dart'
    as _ih79ezm0;
import 'package:garden_server/src/generated/files/file_node.dart' as _il49blua;
import 'package:garden_server/src/generated/files/file_version.dart'
    as _iwzwya1z;
import 'package:garden_server/src/generated/files/uploaded_part.dart'
    as _izqf04mm;
import 'package:garden_server/src/generated/gardens/garden_member.dart'
    as _ii55jf3s;
import 'package:garden_server/src/generated/gardens/garden_summary.dart'
    as _itk3qnhp;
import 'package:garden_server/src/generated/sharing/account_notification.dart'
    as _im5nx011;
import 'package:garden_server/src/generated/sharing/drive_invitation.dart'
    as _i0k70kb6;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
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
import 'future_calls_generated_models/upload_cleanup_future_call_expire_model.dart'
    as _i4nkt2dm;
import 'gardens/account_details.dart' as _i4muwn5e;
import 'gardens/finder_session.dart' as _i14hlkad;
import 'gardens/garden_exception.dart' as _icsgmcpa;
import 'gardens/garden_member.dart' as _icenu3t8;
import 'gardens/garden_record.dart' as _iwqk3oef;
import 'gardens/garden_summary.dart' as _i5zbrq86;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'sharing/account_notification.dart' as _i8nfb11w;
import 'sharing/drive_invitation.dart' as _iks3nfjn;
import 'sharing/drive_management.dart' as _ihkyi9jp;
import 'sharing/drive_member_details.dart' as _iwfm68rt;
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
export 'sharing/account_notification.dart';
export 'sharing/drive_invitation.dart';
export 'sharing/drive_management.dart';
export 'sharing/drive_member_details.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'account_notification',
      dartName: 'AccountNotification',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'recipientEmail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'invitationId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'readAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'notification_recipient_cursor',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientEmail',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'drive_event',
      dartName: 'DriveEvent',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'operation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'authorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'node',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:FileNode?',
        ),
        _isp.ColumnDefinition(
          name: 'previousParentId',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'drive_event_fk_0',
          columns: ['gardenId'],
          referenceTable: 'garden_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'event_revision_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'drive_invitation',
      dartName: 'DriveInvitation',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'inviterId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientEmail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedBy',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'acceptedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'declinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryStatus',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'notConfigured\'',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryMessageId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'deliveryError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'drive_invitation_fk_0',
          columns: ['gardenId'],
          referenceTable: 'garden_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'invitation_recipient',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientEmail',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'file_chunk',
      dartName: 'FileChunk',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'versionId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chunkIndex',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'size',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'checksum',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'file_chunk_fk_0',
          columns: ['versionId'],
          referenceTable: 'file_version',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'chunk_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'versionId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'chunkIndex',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'file_comment',
      dartName: 'FileComment',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'nodeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'file_comment_fk_0',
          columns: ['nodeId'],
          referenceTable: 'file_node',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'comment_node',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nodeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'file_lease',
      dartName: 'FileLease',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'nodeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'holderId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'file_lease_fk_0',
          columns: ['nodeId'],
          referenceTable: 'file_node',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'lease_node_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nodeId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'file_node',
      dartName: 'FileNode',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'parentId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'activeName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:NodeKind',
        ),
        _isp.ColumnDefinition(
          name: 'size',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'deleted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'attributes',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:FileAttributes?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'file_node_fk_0',
          columns: ['gardenId'],
          referenceTable: 'garden_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'node_sibling_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'parentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'activeName',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'node_directory',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'parentId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'deleted',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'file_version',
      dartName: 'FileVersion',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'nodeId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'baseVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'size',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'chunkCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'objectPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'uploadId',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'partSize',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'operationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'editRequest',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'modifiedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'committed',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'aborted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'file_version_fk_0',
          columns: ['nodeId'],
          referenceTable: 'file_node',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'version_edit_operation',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authorId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'operationId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'version_node',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nodeId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'committed',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'filesystem_receipt',
      dartName: 'FilesystemReceipt',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authorId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'request',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:FilesystemRequest',
        ),
        _isp.ColumnDefinition(
          name: 'operationId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'events',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:DriveEvent>',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'filesystem_receipt_fk_0',
          columns: ['gardenId'],
          referenceTable: 'garden_record',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'filesystem_operation_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authorId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'operationId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'garden_member',
      dartName: 'GardenMember',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'gardenId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'userId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'garden_user_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'gardenId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'userId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'garden_record',
      dartName: 'GardenRecord',
      schema: 'public',
      module: 'garden',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'ownerId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'invitationHash',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'deleted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'invitation_hash_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'invitationHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
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
    if (t == _i4nkt2dm.UploadCleanupFutureCallExpireModel) {
      return _i4nkt2dm.UploadCleanupFutureCallExpireModel.fromJson(data) as T;
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
    if (t == _is.getType<_id6mrfn8.ContentDownload?>()) {
      return (data != null ? _id6mrfn8.ContentDownload.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i8kiawn9.DirectoryListing?>()) {
      return (data != null ? _i8kiawn9.DirectoryListing.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i4wn0cbe.DriveEvent?>()) {
      return (data != null ? _i4wn0cbe.DriveEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ir46o6qz.FileAttributes?>()) {
      return (data != null ? _ir46o6qz.FileAttributes.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imjz65yx.FileChunk?>()) {
      return (data != null ? _imjz65yx.FileChunk.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8jjzct9.FileComment?>()) {
      return (data != null ? _i8jjzct9.FileComment.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ifu05pz5.FileLease?>()) {
      return (data != null ? _ifu05pz5.FileLease.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iqxechne.FileNode?>()) {
      return (data != null ? _iqxechne.FileNode.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_inq2edz5.FileVersion?>()) {
      return (data != null ? _inq2edz5.FileVersion.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i0zf8lre.FilesystemError?>()) {
      return (data != null ? _i0zf8lre.FilesystemError.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i97gk0ac.FilesystemException?>()) {
      return (data != null
              ? _i97gk0ac.FilesystemException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ioqlevl0.FilesystemOperation?>()) {
      return (data != null
              ? _ioqlevl0.FilesystemOperation.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iorf3lk3.FilesystemReceipt?>()) {
      return (data != null ? _iorf3lk3.FilesystemReceipt.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_irlkgwt0.FilesystemRequest?>()) {
      return (data != null ? _irlkgwt0.FilesystemRequest.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idxfoob7.NodeKind?>()) {
      return (data != null ? _idxfoob7.NodeKind.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ivsra0vz.UploadedPart?>()) {
      return (data != null ? _ivsra0vz.UploadedPart.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i4nkt2dm.UploadCleanupFutureCallExpireModel?>()) {
      return (data != null
              ? _i4nkt2dm.UploadCleanupFutureCallExpireModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i4muwn5e.AccountDetails?>()) {
      return (data != null ? _i4muwn5e.AccountDetails.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i14hlkad.FinderSession?>()) {
      return (data != null ? _i14hlkad.FinderSession.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icsgmcpa.GardenException?>()) {
      return (data != null ? _icsgmcpa.GardenException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icenu3t8.GardenMember?>()) {
      return (data != null ? _icenu3t8.GardenMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwqk3oef.GardenRecord?>()) {
      return (data != null ? _iwqk3oef.GardenRecord.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5zbrq86.GardenSummary?>()) {
      return (data != null ? _i5zbrq86.GardenSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8nfb11w.AccountNotification?>()) {
      return (data != null
              ? _i8nfb11w.AccountNotification.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iks3nfjn.DriveInvitation?>()) {
      return (data != null ? _iks3nfjn.DriveInvitation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihkyi9jp.DriveManagement?>()) {
      return (data != null ? _ihkyi9jp.DriveManagement.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwfm68rt.DriveMemberDetails?>()) {
      return (data != null ? _iwfm68rt.DriveMemberDetails.fromJson(data) : null)
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
    if (t == _is.getType<Map<String, String>?>()) {
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
    if (t ==
        List<({DateTime createdAt, _is.UuidValue id, _idt.ByteData keyId})>) {
      return (data as List)
              .map(
                (e) =>
                    deserialize<
                      ({
                        DateTime createdAt,
                        _is.UuidValue id,
                        _idt.ByteData keyId,
                      })
                    >(e),
              )
              .toList()
          as T;
    }
    if (t ==
        _is
            .getType<
              ({DateTime createdAt, _is.UuidValue id, _idt.ByteData keyId})
            >()) {
      return (
            createdAt: deserialize<DateTime>(
              ((data as Map)['n'] as Map)['createdAt'],
            ),
            id: deserialize<_is.UuidValue>(data['n']['id']),
            keyId: deserialize<_idt.ByteData>(data['n']['keyId']),
          )
          as T;
    }
    if (t ==
        _is
            .getType<
              ({DateTime createdAt, _is.UuidValue id, _idt.ByteData keyId})
            >()) {
      return (
            createdAt: deserialize<DateTime>(
              ((data as Map)['n'] as Map)['createdAt'],
            ),
            id: deserialize<_is.UuidValue>(data['n']['id']),
            keyId: deserialize<_idt.ByteData>(data['n']['keyId']),
          )
          as T;
    }
    if (t == _is.getType<({_idt.ByteData challenge, _is.UuidValue id})>()) {
      return (
            challenge: deserialize<_idt.ByteData>(
              ((data as Map)['n'] as Map)['challenge'],
            ),
            id: deserialize<_is.UuidValue>(data['n']['id']),
          )
          as T;
    }
    if (t == List<_ih79ezm0.FileComment>) {
      return (data as List)
              .map((e) => deserialize<_ih79ezm0.FileComment>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_izqf04mm.UploadedPart>) {
      return (data as List)
              .map((e) => deserialize<_izqf04mm.UploadedPart>(e))
              .toList()
          as T;
    }
    if (t == List<_iwzwya1z.FileVersion>) {
      return (data as List)
              .map((e) => deserialize<_iwzwya1z.FileVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_ipqwe4ae.DriveEvent>) {
      return (data as List)
              .map((e) => deserialize<_ipqwe4ae.DriveEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_il49blua.FileNode>) {
      return (data as List)
              .map((e) => deserialize<_il49blua.FileNode>(e))
              .toList()
          as T;
    }
    if (t == List<_itk3qnhp.GardenSummary>) {
      return (data as List)
              .map((e) => deserialize<_itk3qnhp.GardenSummary>(e))
              .toList()
          as T;
    }
    if (t == List<_i0k70kb6.DriveInvitation>) {
      return (data as List)
              .map((e) => deserialize<_i0k70kb6.DriveInvitation>(e))
              .toList()
          as T;
    }
    if (t == List<_ii55jf3s.GardenMember>) {
      return (data as List)
              .map((e) => deserialize<_ii55jf3s.GardenMember>(e))
              .toList()
          as T;
    }
    if (t == List<_im5nx011.AccountNotification>) {
      return (data as List)
              .map((e) => deserialize<_im5nx011.AccountNotification>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
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
      _i4nkt2dm.UploadCleanupFutureCallExpireModel =>
        'UploadCleanupFutureCallExpireModel',
      _i4muwn5e.AccountDetails => 'AccountDetails',
      _i14hlkad.FinderSession => 'FinderSession',
      _icsgmcpa.GardenException => 'GardenException',
      _icenu3t8.GardenMember => 'GardenMember',
      _iwqk3oef.GardenRecord => 'GardenRecord',
      _i5zbrq86.GardenSummary => 'GardenSummary',
      _izw8z7ou.Greeting => 'Greeting',
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
      case _i4nkt2dm.UploadCleanupFutureCallExpireModel():
        return 'UploadCleanupFutureCallExpireModel';
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
      case _i8nfb11w.AccountNotification():
        return 'AccountNotification';
      case _iks3nfjn.DriveInvitation():
        return 'DriveInvitation';
      case _ihkyi9jp.DriveManagement():
        return 'DriveManagement';
      case _iwfm68rt.DriveMemberDetails():
        return 'DriveMemberDetails';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
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
    if (dataClassName == 'UploadCleanupFutureCallExpireModel') {
      return deserialize<_i4nkt2dm.UploadCleanupFutureCallExpireModel>(
        data['data'],
      );
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
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('garden', this);
    _iacs.Protocol().registerHostProtocol('garden', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i4wn0cbe.DriveEvent:
        return _i4wn0cbe.DriveEvent.t;
      case _imjz65yx.FileChunk:
        return _imjz65yx.FileChunk.t;
      case _i8jjzct9.FileComment:
        return _i8jjzct9.FileComment.t;
      case _ifu05pz5.FileLease:
        return _ifu05pz5.FileLease.t;
      case _iqxechne.FileNode:
        return _iqxechne.FileNode.t;
      case _inq2edz5.FileVersion:
        return _inq2edz5.FileVersion.t;
      case _iorf3lk3.FilesystemReceipt:
        return _iorf3lk3.FilesystemReceipt.t;
      case _icenu3t8.GardenMember:
        return _icenu3t8.GardenMember.t;
      case _iwqk3oef.GardenRecord:
        return _iwqk3oef.GardenRecord.t;
      case _i8nfb11w.AccountNotification:
        return _i8nfb11w.AccountNotification.t;
      case _iks3nfjn.DriveInvitation:
        return _iks3nfjn.DriveInvitation.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
        is ({DateTime createdAt, _is.UuidValue id, _idt.ByteData keyId})) {
      return {
        "n": {
          "createdAt": record.createdAt.toJson(),
          "id": record.id.toJson(),
          "keyId": record.keyId.toJson(),
        },
      };
    }
    if (record is ({_idt.ByteData challenge, _is.UuidValue id})) {
      return {
        "n": {
          "challenge": record.challenge.toJson(),
          "id": record.id.toJson(),
        },
      };
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
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
