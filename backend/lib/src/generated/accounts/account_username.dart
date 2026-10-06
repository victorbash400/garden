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

abstract class AccountUsername
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  AccountUsername._({
    this.id,
    required this.userId,
    required this.username,
  });

  factory AccountUsername({
    int? id,
    required String userId,
    required String username,
  }) = _AccountUsernameImpl;

  factory AccountUsername.fromJson(Map<String, dynamic> jsonSerialization) {
    return AccountUsername(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      username: jsonSerialization['username'] as String,
    );
  }

  static final t = AccountUsernameTable();

  static const db = AccountUsernameRepository._();

  @override
  int? id;

  String userId;

  String username;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AccountUsername]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AccountUsername copyWith({
    int? id,
    String? userId,
    String? username,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AccountUsername',
      if (id != null) 'id': id,
      'userId': userId,
      'username': username,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AccountUsername',
      if (id != null) 'id': id,
      'userId': userId,
      'username': username,
    };
  }

  static AccountUsernameInclude include() {
    return AccountUsernameInclude._();
  }

  static AccountUsernameIncludeList includeList({
    _is.WhereExpressionBuilder<AccountUsernameTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    AccountUsernameInclude? include,
  }) {
    return AccountUsernameIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AccountUsernameImpl extends AccountUsername {
  _AccountUsernameImpl({
    int? id,
    required String userId,
    required String username,
  }) : super._(
         id: id,
         userId: userId,
         username: username,
       );

  /// Returns a shallow copy of this [AccountUsername]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AccountUsername copyWith({
    Object? id = _Undefined,
    String? userId,
    String? username,
  }) {
    return AccountUsername(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
    );
  }
}

class AccountUsernameUpdateTable extends _is.UpdateTable<AccountUsernameTable> {
  AccountUsernameUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> username(String value) => _is.ColumnValue(
    table.username,
    value,
  );
}

class AccountUsernameTable extends _is.Table<int?> {
  AccountUsernameTable({super.tableRelation})
    : super(tableName: 'account_username') {
    updateTable = AccountUsernameUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    username = _is.ColumnString(
      'username',
      this,
    );
  }

  late final AccountUsernameUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnString username;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    username,
  ];
}

class AccountUsernameInclude extends _is.IncludeObject {
  AccountUsernameInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => AccountUsername.t;
}

class AccountUsernameIncludeList extends _is.IncludeList {
  AccountUsernameIncludeList._({
    _is.WhereExpressionBuilder<AccountUsernameTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AccountUsername.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AccountUsername.t;
}

class AccountUsernameRepository {
  const AccountUsernameRepository._();

  /// Returns a list of [AccountUsername]s matching the given query parameters.
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
  Future<List<AccountUsername>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountUsernameTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AccountUsername>(
      where: where?.call(AccountUsername.t),
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AccountUsername] matching the given query parameters.
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
  Future<AccountUsername?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountUsernameTable>? where,
    int? offset,
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AccountUsername>(
      where: where?.call(AccountUsername.t),
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AccountUsername] by its [id] or null if no such row exists.
  Future<AccountUsername?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AccountUsername>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AccountUsername]s in the list and returns the inserted rows.
  ///
  /// The returned [AccountUsername]s will have their `id` fields set.
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
  Future<List<AccountUsername>> insert(
    _is.DatabaseSession session,
    List<AccountUsername> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AccountUsername>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AccountUsername] and returns the inserted row.
  ///
  /// The returned [AccountUsername] will have its `id` field set.
  Future<AccountUsername> insertRow(
    _is.DatabaseSession session,
    AccountUsername row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AccountUsername>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AccountUsername]s in the list and returns the resulting rows.
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
  /// The returned [AccountUsername]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountUsername>> upsert(
    _is.DatabaseSession session,
    List<AccountUsername> rows, {
    required _is.ColumnSelections<AccountUsernameTable> conflictColumns,
    _is.ColumnSelections<AccountUsernameTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountUsernameTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AccountUsername>(
      rows,
      conflictColumns: conflictColumns(AccountUsername.t),
      updateColumns: updateColumns?.call(AccountUsername.t),
      updateWhere: updateWhere?.call(AccountUsername.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AccountUsername] and returns the resulting row.
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
  /// The returned [AccountUsername] will have its `id` field set.
  Future<AccountUsername?> upsertRow(
    _is.DatabaseSession session,
    AccountUsername row, {
    required _is.ColumnSelections<AccountUsernameTable> conflictColumns,
    _is.ColumnSelections<AccountUsernameTable>? updateColumns,
    _is.WhereExpressionBuilder<AccountUsernameTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AccountUsername>(
      row,
      conflictColumns: conflictColumns(AccountUsername.t),
      updateColumns: updateColumns?.call(AccountUsername.t),
      updateWhere: updateWhere?.call(AccountUsername.t),
      transaction: transaction,
    );
  }

  /// Updates all [AccountUsername]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountUsername>> update(
    _is.DatabaseSession session,
    List<AccountUsername> rows, {
    _is.ColumnSelections<AccountUsernameTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AccountUsername>(
      rows,
      columns: columns?.call(AccountUsername.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AccountUsername]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AccountUsername> updateRow(
    _is.DatabaseSession session,
    AccountUsername row, {
    _is.ColumnSelections<AccountUsernameTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AccountUsername>(
      row,
      columns: columns?.call(AccountUsername.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AccountUsername] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AccountUsername?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AccountUsernameUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AccountUsername>(
      id,
      columnValues: columnValues(AccountUsername.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AccountUsername]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AccountUsername>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AccountUsernameUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<AccountUsernameTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AccountUsername>(
      columnValues: columnValues(AccountUsername.t.updateTable),
      where: where(AccountUsername.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AccountUsername]s in the list and returns the deleted rows.
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
  Future<List<AccountUsername>> delete(
    _is.DatabaseSession session,
    List<AccountUsername> rows, {
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AccountUsername>(
      rows,
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AccountUsername].
  Future<AccountUsername> deleteRow(
    _is.DatabaseSession session,
    AccountUsername row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AccountUsername>(
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
  Future<List<AccountUsername>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountUsernameTable> where,
    _is.OrderByBuilder<AccountUsernameTable>? orderBy,
    _is.OrderByListBuilder<AccountUsernameTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AccountUsername>(
      where: where(AccountUsername.t),
      orderBy: orderBy?.call(AccountUsername.t),
      orderByList: orderByList?.call(AccountUsername.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AccountUsernameTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AccountUsername>(
      where: where?.call(AccountUsername.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AccountUsername] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AccountUsernameTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AccountUsername>(
      where: where(AccountUsername.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
