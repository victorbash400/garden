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

abstract class DriveInvitation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DriveInvitation._({
    this.id,
    required this.gardenId,
    required this.inviterId,
    required this.recipientEmail,
    required this.role,
    required this.expiresAt,
    required this.createdAt,
    this.acceptedBy,
    this.acceptedAt,
    this.declinedAt,
    this.revokedAt,
    String? deliveryStatus,
    this.deliveryMessageId,
    this.deliveryError,
  }) : deliveryStatus = deliveryStatus ?? 'notConfigured';

  factory DriveInvitation({
    int? id,
    required int gardenId,
    required String inviterId,
    required String recipientEmail,
    required String role,
    required DateTime expiresAt,
    required DateTime createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  }) = _DriveInvitationImpl;

  factory DriveInvitation.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveInvitation(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      inviterId: jsonSerialization['inviterId'] as String,
      recipientEmail: jsonSerialization['recipientEmail'] as String,
      role: jsonSerialization['role'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      acceptedBy: jsonSerialization['acceptedBy'] as String?,
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      declinedAt: jsonSerialization['declinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['declinedAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      deliveryStatus: jsonSerialization['deliveryStatus'] as String?,
      deliveryMessageId: jsonSerialization['deliveryMessageId'] as String?,
      deliveryError: jsonSerialization['deliveryError'] as String?,
    );
  }

  static final t = DriveInvitationTable();

  static const db = DriveInvitationRepository._();

  @override
  int? id;

  int gardenId;

  String inviterId;

  String recipientEmail;

  String role;

  DateTime expiresAt;

  DateTime createdAt;

  String? acceptedBy;

  DateTime? acceptedAt;

  DateTime? declinedAt;

  DateTime? revokedAt;

  String deliveryStatus;

  String? deliveryMessageId;

  String? deliveryError;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DriveInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DriveInvitation copyWith({
    int? id,
    int? gardenId,
    String? inviterId,
    String? recipientEmail,
    String? role,
    DateTime? expiresAt,
    DateTime? createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveInvitation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'inviterId': inviterId,
      'recipientEmail': recipientEmail,
      'role': role,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (declinedAt != null) 'declinedAt': declinedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'deliveryStatus': deliveryStatus,
      if (deliveryMessageId != null) 'deliveryMessageId': deliveryMessageId,
      if (deliveryError != null) 'deliveryError': deliveryError,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveInvitation',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'inviterId': inviterId,
      'recipientEmail': recipientEmail,
      'role': role,
      'expiresAt': expiresAt.toJson(),
      'createdAt': createdAt.toJson(),
      if (acceptedBy != null) 'acceptedBy': acceptedBy,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (declinedAt != null) 'declinedAt': declinedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      'deliveryStatus': deliveryStatus,
      if (deliveryMessageId != null) 'deliveryMessageId': deliveryMessageId,
      if (deliveryError != null) 'deliveryError': deliveryError,
    };
  }

  static DriveInvitationInclude include() {
    return DriveInvitationInclude._();
  }

  static DriveInvitationIncludeList includeList({
    _is.WhereExpressionBuilder<DriveInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    DriveInvitationInclude? include,
  }) {
    return DriveInvitationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveInvitationImpl extends DriveInvitation {
  _DriveInvitationImpl({
    int? id,
    required int gardenId,
    required String inviterId,
    required String recipientEmail,
    required String role,
    required DateTime expiresAt,
    required DateTime createdAt,
    String? acceptedBy,
    DateTime? acceptedAt,
    DateTime? declinedAt,
    DateTime? revokedAt,
    String? deliveryStatus,
    String? deliveryMessageId,
    String? deliveryError,
  }) : super._(
         id: id,
         gardenId: gardenId,
         inviterId: inviterId,
         recipientEmail: recipientEmail,
         role: role,
         expiresAt: expiresAt,
         createdAt: createdAt,
         acceptedBy: acceptedBy,
         acceptedAt: acceptedAt,
         declinedAt: declinedAt,
         revokedAt: revokedAt,
         deliveryStatus: deliveryStatus,
         deliveryMessageId: deliveryMessageId,
         deliveryError: deliveryError,
       );

  /// Returns a shallow copy of this [DriveInvitation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DriveInvitation copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? inviterId,
    String? recipientEmail,
    String? role,
    DateTime? expiresAt,
    DateTime? createdAt,
    Object? acceptedBy = _Undefined,
    Object? acceptedAt = _Undefined,
    Object? declinedAt = _Undefined,
    Object? revokedAt = _Undefined,
    String? deliveryStatus,
    Object? deliveryMessageId = _Undefined,
    Object? deliveryError = _Undefined,
  }) {
    return DriveInvitation(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      inviterId: inviterId ?? this.inviterId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      acceptedBy: acceptedBy is String? ? acceptedBy : this.acceptedBy,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      declinedAt: declinedAt is DateTime? ? declinedAt : this.declinedAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryMessageId: deliveryMessageId is String?
          ? deliveryMessageId
          : this.deliveryMessageId,
      deliveryError: deliveryError is String?
          ? deliveryError
          : this.deliveryError,
    );
  }
}

class DriveInvitationUpdateTable extends _is.UpdateTable<DriveInvitationTable> {
  DriveInvitationUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<String, String> inviterId(String value) => _is.ColumnValue(
    table.inviterId,
    value,
  );

  _is.ColumnValue<String, String> recipientEmail(String value) =>
      _is.ColumnValue(
        table.recipientEmail,
        value,
      );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<String, String> acceptedBy(String? value) => _is.ColumnValue(
    table.acceptedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> declinedAt(DateTime? value) =>
      _is.ColumnValue(
        table.declinedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );

  _is.ColumnValue<String, String> deliveryStatus(String value) =>
      _is.ColumnValue(
        table.deliveryStatus,
        value,
      );

  _is.ColumnValue<String, String> deliveryMessageId(String? value) =>
      _is.ColumnValue(
        table.deliveryMessageId,
        value,
      );

  _is.ColumnValue<String, String> deliveryError(String? value) =>
      _is.ColumnValue(
        table.deliveryError,
        value,
      );
}

class DriveInvitationTable extends _is.Table<int?> {
  DriveInvitationTable({super.tableRelation})
    : super(tableName: 'drive_invitation') {
    updateTable = DriveInvitationUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    inviterId = _is.ColumnString(
      'inviterId',
      this,
    );
    recipientEmail = _is.ColumnString(
      'recipientEmail',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    acceptedBy = _is.ColumnString(
      'acceptedBy',
      this,
    );
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
    );
    declinedAt = _is.ColumnDateTime(
      'declinedAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
    deliveryStatus = _is.ColumnString(
      'deliveryStatus',
      this,
      hasDefault: true,
    );
    deliveryMessageId = _is.ColumnString(
      'deliveryMessageId',
      this,
    );
    deliveryError = _is.ColumnString(
      'deliveryError',
      this,
    );
  }

  late final DriveInvitationUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnString inviterId;

  late final _is.ColumnString recipientEmail;

  late final _is.ColumnString role;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnString acceptedBy;

  late final _is.ColumnDateTime acceptedAt;

  late final _is.ColumnDateTime declinedAt;

  late final _is.ColumnDateTime revokedAt;

  late final _is.ColumnString deliveryStatus;

  late final _is.ColumnString deliveryMessageId;

  late final _is.ColumnString deliveryError;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    inviterId,
    recipientEmail,
    role,
    expiresAt,
    createdAt,
    acceptedBy,
    acceptedAt,
    declinedAt,
    revokedAt,
    deliveryStatus,
    deliveryMessageId,
    deliveryError,
  ];
}

class DriveInvitationInclude extends _is.IncludeObject {
  DriveInvitationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DriveInvitation.t;
}

class DriveInvitationIncludeList extends _is.IncludeList {
  DriveInvitationIncludeList._({
    _is.WhereExpressionBuilder<DriveInvitationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DriveInvitation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DriveInvitation.t;
}

class DriveInvitationRepository {
  const DriveInvitationRepository._();

  /// Returns a list of [DriveInvitation]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<DriveInvitation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveInvitationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DriveInvitation>(
      where: where?.call(DriveInvitation.t),
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DriveInvitation] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<DriveInvitation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveInvitationTable>? where,
    int? offset,
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DriveInvitation>(
      where: where?.call(DriveInvitation.t),
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DriveInvitation] by its [id] or null if no such row exists.
  Future<DriveInvitation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DriveInvitation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DriveInvitation]s in the list and returns the inserted rows.
  ///
  /// The returned [DriveInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> insert(
    _is.DatabaseSession session,
    List<DriveInvitation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DriveInvitation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DriveInvitation] and returns the inserted row.
  ///
  /// The returned [DriveInvitation] will have its `id` field set.
  Future<DriveInvitation> insertRow(
    _is.DatabaseSession session,
    DriveInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DriveInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DriveInvitation]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [DriveInvitation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> upsert(
    _is.DatabaseSession session,
    List<DriveInvitation> rows, {
    required _is.ColumnSelections<DriveInvitationTable> conflictColumns,
    _is.ColumnSelections<DriveInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveInvitationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DriveInvitation>(
      rows,
      conflictColumns: conflictColumns(DriveInvitation.t),
      updateColumns: updateColumns?.call(DriveInvitation.t),
      updateWhere: updateWhere?.call(DriveInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DriveInvitation] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [DriveInvitation] will have its `id` field set.
  Future<DriveInvitation?> upsertRow(
    _is.DatabaseSession session,
    DriveInvitation row, {
    required _is.ColumnSelections<DriveInvitationTable> conflictColumns,
    _is.ColumnSelections<DriveInvitationTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveInvitationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DriveInvitation>(
      row,
      conflictColumns: conflictColumns(DriveInvitation.t),
      updateColumns: updateColumns?.call(DriveInvitation.t),
      updateWhere: updateWhere?.call(DriveInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates all [DriveInvitation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> update(
    _is.DatabaseSession session,
    List<DriveInvitation> rows, {
    _is.ColumnSelections<DriveInvitationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DriveInvitation>(
      rows,
      columns: columns?.call(DriveInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DriveInvitation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DriveInvitation> updateRow(
    _is.DatabaseSession session,
    DriveInvitation row, {
    _is.ColumnSelections<DriveInvitationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DriveInvitation>(
      row,
      columns: columns?.call(DriveInvitation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DriveInvitation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DriveInvitation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DriveInvitationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DriveInvitation>(
      id,
      columnValues: columnValues(DriveInvitation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DriveInvitation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DriveInvitationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DriveInvitationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DriveInvitation>(
      columnValues: columnValues(DriveInvitation.t.updateTable),
      where: where(DriveInvitation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DriveInvitation]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> delete(
    _is.DatabaseSession session,
    List<DriveInvitation> rows, {
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DriveInvitation>(
      rows,
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DriveInvitation].
  Future<DriveInvitation> deleteRow(
    _is.DatabaseSession session,
    DriveInvitation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DriveInvitation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveInvitation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveInvitationTable> where,
    _is.OrderByBuilder<DriveInvitationTable>? orderBy,
    _is.OrderByListBuilder<DriveInvitationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DriveInvitation>(
      where: where(DriveInvitation.t),
      orderBy: orderBy?.call(DriveInvitation.t),
      orderByList: orderByList?.call(DriveInvitation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveInvitationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DriveInvitation>(
      where: where?.call(DriveInvitation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DriveInvitation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveInvitationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DriveInvitation>(
      where: where(DriveInvitation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
