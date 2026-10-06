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

abstract class AccountNotification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AccountNotification._({
    this.id,
    required this.recipientEmail,
    this.gardenId,
    this.invitationId,
    required this.kind,
    required this.title,
    required this.createdAt,
    this.readAt,
    this.trashedAt,
  });

  factory AccountNotification({
    int? id,
    required String recipientEmail,
    int? gardenId,
    int? invitationId,
    required String kind,
    required String title,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  }) = _AccountNotificationImpl;

  factory AccountNotification.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountNotification(
      id: jsonSerialization['id'] as int?,
      recipientEmail: jsonSerialization['recipientEmail'] as String,
      gardenId: jsonSerialization['gardenId'] as int?,
      invitationId: jsonSerialization['invitationId'] as int?,
      kind: jsonSerialization['kind'] as String,
      title: jsonSerialization['title'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      readAt: jsonSerialization['readAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['readAt']),
      trashedAt: jsonSerialization['trashedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['trashedAt']),
    );
  }

  static final t = AccountNotificationTable();

  static const db = AccountNotificationRepository._();

  @override
  int? id;

  String recipientEmail;

  int? gardenId;

  int? invitationId;

  String kind;

  String title;

  DateTime createdAt;

  DateTime? readAt;

  DateTime? trashedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountNotification copyWith({
    int? id,
    String? recipientEmail,
    int? gardenId,
    int? invitationId,
    String? kind,
    String? title,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountNotification',
      if (id != null) 'id': id,
      'recipientEmail': recipientEmail,
      if (gardenId != null) 'gardenId': gardenId,
      if (invitationId != null) 'invitationId': invitationId,
      'kind': kind,
      'title': title,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
      if (trashedAt != null) 'trashedAt': trashedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountNotification',
      if (id != null) 'id': id,
      'recipientEmail': recipientEmail,
      if (gardenId != null) 'gardenId': gardenId,
      if (invitationId != null) 'invitationId': invitationId,
      'kind': kind,
      'title': title,
      'createdAt': createdAt.toJson(),
      if (readAt != null) 'readAt': readAt?.toJson(),
      if (trashedAt != null) 'trashedAt': trashedAt?.toJson(),
    };
  }

  static AccountNotificationInclude include() {
    return AccountNotificationInclude._();
  }

  static AccountNotificationIncludeList includeList({
    _is.WhereExpressionBuilder<AccountNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    AccountNotificationInclude? include,
  }) {
    return AccountNotificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountNotificationImpl extends AccountNotification {
  _AccountNotificationImpl({
    int? id,
    required String recipientEmail,
    int? gardenId,
    int? invitationId,
    required String kind,
    required String title,
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? trashedAt,
  }) : super._(
         id: id,
         recipientEmail: recipientEmail,
         gardenId: gardenId,
         invitationId: invitationId,
         kind: kind,
         title: title,
         createdAt: createdAt,
         readAt: readAt,
         trashedAt: trashedAt,
       );

  /// Returns a shallow copy of this [AccountNotification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountNotification copyWith({
    Object? id = _Undefined,
    String? recipientEmail,
    Object? gardenId = _Undefined,
    Object? invitationId = _Undefined,
    String? kind,
    String? title,
    DateTime? createdAt,
    Object? readAt = _Undefined,
    Object? trashedAt = _Undefined,
  }) {
    return AccountNotification(
      id: id is int? ? id : this.id,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      gardenId: gardenId is int? ? gardenId : this.gardenId,
      invitationId: invitationId is int? ? invitationId : this.invitationId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt is DateTime? ? readAt : this.readAt,
      trashedAt: trashedAt is DateTime? ? trashedAt : this.trashedAt,
    );
  }
}

class AccountNotificationUpdateTable
    extends _is.UpdateTable<AccountNotificationTable> {
  AccountNotificationUpdateTable(super.table);

  _is.ColumnValue<String, String> recipientEmail(String value) =>
      _is.ColumnValue(
        table.recipientEmail,
        value,
      );

  _is.ColumnValue<int, int> gardenId(int? value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<int, int> invitationId(int? value) => _is.ColumnValue(
    table.invitationId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> readAt(DateTime? value) =>
      _is.ColumnValue(
        table.readAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> trashedAt(DateTime? value) =>
      _is.ColumnValue(
        table.trashedAt,
        value,
      );
}

class AccountNotificationTable extends _is.Table<int?> {
  AccountNotificationTable({super.tableRelation})
    : super(tableName: 'account_notification') {
    updateTable = AccountNotificationUpdateTable(this);
    recipientEmail = _is.ColumnString(
      'recipientEmail',
      this,
    );
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    invitationId = _is.ColumnInt(
      'invitationId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    readAt = _is.ColumnDateTime(
      'readAt',
      this,
    );
    trashedAt = _is.ColumnDateTime(
      'trashedAt',
      this,
    );
  }

  late final AccountNotificationUpdateTable updateTable;

  late final _is.ColumnString recipientEmail;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnInt invitationId;

  late final _is.ColumnString kind;

  late final _is.ColumnString title;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime readAt;

  late final _is.ColumnDateTime trashedAt;

  @override
  List<_is.Column> get columns => [
    id,
    recipientEmail,
    gardenId,
    invitationId,
    kind,
    title,
    createdAt,
    readAt,
    trashedAt,
  ];
}

class AccountNotificationInclude extends _is.IncludeObject {
  AccountNotificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AccountNotification.t;
}

class AccountNotificationIncludeList extends _is.IncludeList {
  AccountNotificationIncludeList._({
    _is.WhereExpressionBuilder<AccountNotificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountNotification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AccountNotification.t;
}

class AccountNotificationRepository {
  const AccountNotificationRepository._();

  /// Returns a list of [AccountNotification]s matching the given query parameters.
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
  Future<List<AccountNotification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountNotificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountNotification>(
      where: where?.call(AccountNotification.t),
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccountNotification] matching the given query parameters.
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
  Future<AccountNotification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountNotificationTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountNotification>(
      where: where?.call(AccountNotification.t),
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountNotification] by its [id] or null if no such row exists.
  Future<AccountNotification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountNotification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountNotification]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountNotification]s will have their `id` fields set.
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
  Future<List<AccountNotification>> insert(
    _is.DatabaseSession session,
    List<AccountNotification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountNotification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountNotification] and returns the inserted row.
  ///
  /// The returned [AccountNotification] will have its `id` field set.
  Future<AccountNotification> insertRow(
    _is.DatabaseSession session,
    AccountNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountNotification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccountNotification]s in the list and returns the resulting rows.
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
  /// The returned [AccountNotification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountNotification>> upsert(
    _is.DatabaseSession session,
    List<AccountNotification> rows, {
    required _is.ColumnSelections<AccountNotificationTable> conflictColumns,
    _is.ColumnSelections<AccountNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountNotificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountNotification>(
      rows,
      conflictColumns: conflictColumns(AccountNotification.t),
      updateColumns: updateColumns?.call(AccountNotification.t),
      updateWhere: updateWhere?.call(AccountNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountNotification] and returns the resulting row.
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
  /// The returned [AccountNotification] will have its `id` field set.
  Future<AccountNotification?> upsertRow(
    _is.DatabaseSession session,
    AccountNotification row, {
    required _is.ColumnSelections<AccountNotificationTable> conflictColumns,
    _is.ColumnSelections<AccountNotificationTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountNotificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountNotification>(
      row,
      conflictColumns: conflictColumns(AccountNotification.t),
      updateColumns: updateColumns?.call(AccountNotification.t),
      updateWhere: updateWhere?.call(AccountNotification.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountNotification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountNotification>> update(
    _is.DatabaseSession session,
    List<AccountNotification> rows, {
    _is.ColumnSelections<AccountNotificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountNotification>(
      rows,
      columns: columns?.call(AccountNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountNotification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountNotification> updateRow(
    _is.DatabaseSession session,
    AccountNotification row, {
    _is.ColumnSelections<AccountNotificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountNotification>(
      row,
      columns: columns?.call(AccountNotification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountNotification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountNotification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AccountNotificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountNotification>(
      id,
      columnValues: columnValues(AccountNotification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountNotification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountNotification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountNotificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccountNotificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountNotification>(
      columnValues: columnValues(AccountNotification.t.updateTable),
      where: where(AccountNotification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountNotification]s in the list and returns the deleted rows.
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
  Future<List<AccountNotification>> delete(
    _is.DatabaseSession session,
    List<AccountNotification> rows, {
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountNotification>(
      rows,
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountNotification].
  Future<AccountNotification> deleteRow(
    _is.DatabaseSession session,
    AccountNotification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountNotification>(
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
  Future<List<AccountNotification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountNotificationTable> where,
    _is.OrderByBuilder<AccountNotificationTable>? orderBy,
    _is.OrderByListBuilder<AccountNotificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountNotification>(
      where: where(AccountNotification.t),
      orderBy: orderBy?.call(AccountNotification.t),
      orderByList: orderByList?.call(AccountNotification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountNotificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountNotification>(
      where: where?.call(AccountNotification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountNotification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountNotificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountNotification>(
      where: where(AccountNotification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
