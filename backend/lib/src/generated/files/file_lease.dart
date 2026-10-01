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

abstract class FileLease
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FileLease._({
    this.id,
    required this.nodeId,
    required this.holderId,
    required this.token,
    required this.expiresAt,
  });

  factory FileLease({
    int? id,
    required int nodeId,
    required String holderId,
    required String token,
    required DateTime expiresAt,
  }) = _FileLeaseImpl;

  factory FileLease.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileLease(
      id: jsonSerialization['id'] as int?,
      nodeId: jsonSerialization['nodeId'] as int,
      holderId: jsonSerialization['holderId'] as String,
      token: jsonSerialization['token'] as String,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = FileLeaseTable();

  static const db = FileLeaseRepository._();

  @override
  int? id;

  int nodeId;

  String holderId;

  String token;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FileLease]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FileLease copyWith({
    int? id,
    int? nodeId,
    String? holderId,
    String? token,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileLease',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'holderId': holderId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileLease',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'holderId': holderId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
    };
  }

  static FileLeaseInclude include() {
    return FileLeaseInclude._();
  }

  static FileLeaseIncludeList includeList({
    _is.WhereExpressionBuilder<FileLeaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    FileLeaseInclude? include,
  }) {
    return FileLeaseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileLeaseImpl extends FileLease {
  _FileLeaseImpl({
    int? id,
    required int nodeId,
    required String holderId,
    required String token,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         nodeId: nodeId,
         holderId: holderId,
         token: token,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [FileLease]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FileLease copyWith({
    Object? id = _Undefined,
    int? nodeId,
    String? holderId,
    String? token,
    DateTime? expiresAt,
  }) {
    return FileLease(
      id: id is int? ? id : this.id,
      nodeId: nodeId ?? this.nodeId,
      holderId: holderId ?? this.holderId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class FileLeaseUpdateTable extends _is.UpdateTable<FileLeaseTable> {
  FileLeaseUpdateTable(super.table);

  _is.ColumnValue<int, int> nodeId(int value) => _is.ColumnValue(
    table.nodeId,
    value,
  );

  _is.ColumnValue<String, String> holderId(String value) => _is.ColumnValue(
    table.holderId,
    value,
  );

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class FileLeaseTable extends _is.Table<int?> {
  FileLeaseTable({super.tableRelation}) : super(tableName: 'file_lease') {
    updateTable = FileLeaseUpdateTable(this);
    nodeId = _is.ColumnInt(
      'nodeId',
      this,
    );
    holderId = _is.ColumnString(
      'holderId',
      this,
    );
    token = _is.ColumnString(
      'token',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final FileLeaseUpdateTable updateTable;

  late final _is.ColumnInt nodeId;

  late final _is.ColumnString holderId;

  late final _is.ColumnString token;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    nodeId,
    holderId,
    token,
    expiresAt,
  ];
}

class FileLeaseInclude extends _is.IncludeObject {
  FileLeaseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FileLease.t;
}

class FileLeaseIncludeList extends _is.IncludeList {
  FileLeaseIncludeList._({
    _is.WhereExpressionBuilder<FileLeaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FileLease.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FileLease.t;
}

class FileLeaseRepository {
  const FileLeaseRepository._();

  /// Returns a list of [FileLease]s matching the given query parameters.
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
  Future<List<FileLease>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileLeaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FileLease>(
      where: where?.call(FileLease.t),
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FileLease] matching the given query parameters.
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
  Future<FileLease?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileLeaseTable>? where,
    int? offset,
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FileLease>(
      where: where?.call(FileLease.t),
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FileLease] by its [id] or null if no such row exists.
  Future<FileLease?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FileLease>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FileLease]s in the list and returns the inserted rows.
  ///
  /// The returned [FileLease]s will have their `id` fields set.
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
  Future<List<FileLease>> insert(
    _is.DatabaseSession session,
    List<FileLease> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FileLease>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FileLease] and returns the inserted row.
  ///
  /// The returned [FileLease] will have its `id` field set.
  Future<FileLease> insertRow(
    _is.DatabaseSession session,
    FileLease row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FileLease>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FileLease]s in the list and returns the resulting rows.
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
  /// The returned [FileLease]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileLease>> upsert(
    _is.DatabaseSession session,
    List<FileLease> rows, {
    required _is.ColumnSelections<FileLeaseTable> conflictColumns,
    _is.ColumnSelections<FileLeaseTable>? updateColumns,
    _is.WhereExpressionBuilder<FileLeaseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FileLease>(
      rows,
      conflictColumns: conflictColumns(FileLease.t),
      updateColumns: updateColumns?.call(FileLease.t),
      updateWhere: updateWhere?.call(FileLease.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FileLease] and returns the resulting row.
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
  /// The returned [FileLease] will have its `id` field set.
  Future<FileLease?> upsertRow(
    _is.DatabaseSession session,
    FileLease row, {
    required _is.ColumnSelections<FileLeaseTable> conflictColumns,
    _is.ColumnSelections<FileLeaseTable>? updateColumns,
    _is.WhereExpressionBuilder<FileLeaseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FileLease>(
      row,
      conflictColumns: conflictColumns(FileLease.t),
      updateColumns: updateColumns?.call(FileLease.t),
      updateWhere: updateWhere?.call(FileLease.t),
      transaction: transaction,
    );
  }

  /// Updates all [FileLease]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileLease>> update(
    _is.DatabaseSession session,
    List<FileLease> rows, {
    _is.ColumnSelections<FileLeaseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FileLease>(
      rows,
      columns: columns?.call(FileLease.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FileLease]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FileLease> updateRow(
    _is.DatabaseSession session,
    FileLease row, {
    _is.ColumnSelections<FileLeaseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FileLease>(
      row,
      columns: columns?.call(FileLease.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileLease] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FileLease?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FileLeaseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FileLease>(
      id,
      columnValues: columnValues(FileLease.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FileLease]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileLease>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FileLeaseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FileLeaseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FileLease>(
      columnValues: columnValues(FileLease.t.updateTable),
      where: where(FileLease.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FileLease]s in the list and returns the deleted rows.
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
  Future<List<FileLease>> delete(
    _is.DatabaseSession session,
    List<FileLease> rows, {
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FileLease>(
      rows,
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FileLease].
  Future<FileLease> deleteRow(
    _is.DatabaseSession session,
    FileLease row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FileLease>(
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
  Future<List<FileLease>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileLeaseTable> where,
    _is.OrderByBuilder<FileLeaseTable>? orderBy,
    _is.OrderByListBuilder<FileLeaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FileLease>(
      where: where(FileLease.t),
      orderBy: orderBy?.call(FileLease.t),
      orderByList: orderByList?.call(FileLease.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileLeaseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FileLease>(
      where: where?.call(FileLease.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FileLease] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileLeaseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FileLease>(
      where: where(FileLease.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
