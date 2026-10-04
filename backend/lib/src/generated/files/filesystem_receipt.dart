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
import '../files/drive_event.dart' as _inr98x4d;
import '../files/filesystem_request.dart' as _iielzn32;

abstract class FilesystemReceipt
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FilesystemReceipt._({
    this.id,
    required this.gardenId,
    required this.authorId,
    required this.request,
    required this.operationId,
    required this.events,
  });

  factory FilesystemReceipt({
    int? id,
    required int gardenId,
    required String authorId,
    required _iielzn32.FilesystemRequest request,
    required _is.UuidValue operationId,
    required List<_inr98x4d.DriveEvent> events,
  }) = _FilesystemReceiptImpl;

  factory FilesystemReceipt.fromJson(Map<String, dynamic> jsonSerialization) {
    return FilesystemReceipt(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      authorId: jsonSerialization['authorId'] as String,
      request: _ipujdd36.Protocol().deserialize<_iielzn32.FilesystemRequest>(
        jsonSerialization['request'],
      ),
      operationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['operationId'],
      ),
      events: _ipujdd36.Protocol().deserialize<List<_inr98x4d.DriveEvent>>(
        jsonSerialization['events'],
      ),
    );
  }

  static final t = FilesystemReceiptTable();

  static const db = FilesystemReceiptRepository._();

  @override
  int? id;

  int gardenId;

  String authorId;

  _iielzn32.FilesystemRequest request;

  _is.UuidValue operationId;

  List<_inr98x4d.DriveEvent> events;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FilesystemReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FilesystemReceipt copyWith({
    int? id,
    int? gardenId,
    String? authorId,
    _iielzn32.FilesystemRequest? request,
    _is.UuidValue? operationId,
    List<_inr98x4d.DriveEvent>? events,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FilesystemReceipt',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'authorId': authorId,
      'request': request.toJson(),
      'operationId': operationId.toJson(),
      'events': events.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FilesystemReceipt',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'authorId': authorId,
      'request': request.toJsonForProtocol(),
      'operationId': operationId.toJson(),
      'events': events.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  static FilesystemReceiptInclude include() {
    return FilesystemReceiptInclude._();
  }

  static FilesystemReceiptIncludeList includeList({
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    FilesystemReceiptInclude? include,
  }) {
    return FilesystemReceiptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FilesystemReceiptImpl extends FilesystemReceipt {
  _FilesystemReceiptImpl({
    int? id,
    required int gardenId,
    required String authorId,
    required _iielzn32.FilesystemRequest request,
    required _is.UuidValue operationId,
    required List<_inr98x4d.DriveEvent> events,
  }) : super._(
         id: id,
         gardenId: gardenId,
         authorId: authorId,
         request: request,
         operationId: operationId,
         events: events,
       );

  /// Returns a shallow copy of this [FilesystemReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FilesystemReceipt copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? authorId,
    _iielzn32.FilesystemRequest? request,
    _is.UuidValue? operationId,
    List<_inr98x4d.DriveEvent>? events,
  }) {
    return FilesystemReceipt(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      authorId: authorId ?? this.authorId,
      request: request ?? this.request.copyWith(),
      operationId: operationId ?? this.operationId,
      events: events ?? this.events.map((e0) => e0.copyWith()).toList(),
    );
  }
}

class FilesystemReceiptUpdateTable
    extends _is.UpdateTable<FilesystemReceiptTable> {
  FilesystemReceiptUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<String, String> authorId(String value) => _is.ColumnValue(
    table.authorId,
    value,
  );

  _is.ColumnValue<_iielzn32.FilesystemRequest, _iielzn32.FilesystemRequest>
  request(_iielzn32.FilesystemRequest value) => _is.ColumnValue(
    table.request,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> operationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.operationId,
    value,
  );

  _is.ColumnValue<List<_inr98x4d.DriveEvent>, List<_inr98x4d.DriveEvent>>
  events(List<_inr98x4d.DriveEvent> value) => _is.ColumnValue(
    table.events,
    value,
  );
}

class FilesystemReceiptTable extends _is.Table<int?> {
  FilesystemReceiptTable({super.tableRelation})
    : super(tableName: 'filesystem_receipt') {
    updateTable = FilesystemReceiptUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    authorId = _is.ColumnString(
      'authorId',
      this,
    );
    request = _is.ColumnSerializable<_iielzn32.FilesystemRequest>(
      'request',
      this,
    );
    operationId = _is.ColumnUuid(
      'operationId',
      this,
    );
    events = _is.ColumnSerializable<List<_inr98x4d.DriveEvent>>(
      'events',
      this,
    );
  }

  late final FilesystemReceiptUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnString authorId;

  late final _is.ColumnSerializable<_iielzn32.FilesystemRequest> request;

  late final _is.ColumnUuid operationId;

  late final _is.ColumnSerializable<List<_inr98x4d.DriveEvent>> events;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    authorId,
    request,
    operationId,
    events,
  ];
}

class FilesystemReceiptInclude extends _is.IncludeObject {
  FilesystemReceiptInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FilesystemReceipt.t;
}

class FilesystemReceiptIncludeList extends _is.IncludeList {
  FilesystemReceiptIncludeList._({
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FilesystemReceipt.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FilesystemReceipt.t;
}

class FilesystemReceiptRepository {
  const FilesystemReceiptRepository._();

  /// Returns a list of [FilesystemReceipt]s matching the given query parameters.
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
  Future<List<FilesystemReceipt>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FilesystemReceipt>(
      where: where?.call(FilesystemReceipt.t),
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FilesystemReceipt] matching the given query parameters.
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
  Future<FilesystemReceipt?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? where,
    int? offset,
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FilesystemReceipt>(
      where: where?.call(FilesystemReceipt.t),
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FilesystemReceipt] by its [id] or null if no such row exists.
  Future<FilesystemReceipt?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FilesystemReceipt>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FilesystemReceipt]s in the list and returns the inserted rows.
  ///
  /// The returned [FilesystemReceipt]s will have their `id` fields set.
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
  Future<List<FilesystemReceipt>> insert(
    _is.DatabaseSession session,
    List<FilesystemReceipt> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FilesystemReceipt>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FilesystemReceipt] and returns the inserted row.
  ///
  /// The returned [FilesystemReceipt] will have its `id` field set.
  Future<FilesystemReceipt> insertRow(
    _is.DatabaseSession session,
    FilesystemReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FilesystemReceipt>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FilesystemReceipt]s in the list and returns the resulting rows.
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
  /// The returned [FilesystemReceipt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FilesystemReceipt>> upsert(
    _is.DatabaseSession session,
    List<FilesystemReceipt> rows, {
    required _is.ColumnSelections<FilesystemReceiptTable> conflictColumns,
    _is.ColumnSelections<FilesystemReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FilesystemReceipt>(
      rows,
      conflictColumns: conflictColumns(FilesystemReceipt.t),
      updateColumns: updateColumns?.call(FilesystemReceipt.t),
      updateWhere: updateWhere?.call(FilesystemReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FilesystemReceipt] and returns the resulting row.
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
  /// The returned [FilesystemReceipt] will have its `id` field set.
  Future<FilesystemReceipt?> upsertRow(
    _is.DatabaseSession session,
    FilesystemReceipt row, {
    required _is.ColumnSelections<FilesystemReceiptTable> conflictColumns,
    _is.ColumnSelections<FilesystemReceiptTable>? updateColumns,
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FilesystemReceipt>(
      row,
      conflictColumns: conflictColumns(FilesystemReceipt.t),
      updateColumns: updateColumns?.call(FilesystemReceipt.t),
      updateWhere: updateWhere?.call(FilesystemReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates all [FilesystemReceipt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FilesystemReceipt>> update(
    _is.DatabaseSession session,
    List<FilesystemReceipt> rows, {
    _is.ColumnSelections<FilesystemReceiptTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FilesystemReceipt>(
      rows,
      columns: columns?.call(FilesystemReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FilesystemReceipt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FilesystemReceipt> updateRow(
    _is.DatabaseSession session,
    FilesystemReceipt row, {
    _is.ColumnSelections<FilesystemReceiptTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FilesystemReceipt>(
      row,
      columns: columns?.call(FilesystemReceipt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FilesystemReceipt] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FilesystemReceipt?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FilesystemReceiptUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FilesystemReceipt>(
      id,
      columnValues: columnValues(FilesystemReceipt.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FilesystemReceipt]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FilesystemReceipt>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FilesystemReceiptUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<FilesystemReceiptTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FilesystemReceipt>(
      columnValues: columnValues(FilesystemReceipt.t.updateTable),
      where: where(FilesystemReceipt.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FilesystemReceipt]s in the list and returns the deleted rows.
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
  Future<List<FilesystemReceipt>> delete(
    _is.DatabaseSession session,
    List<FilesystemReceipt> rows, {
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FilesystemReceipt>(
      rows,
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FilesystemReceipt].
  Future<FilesystemReceipt> deleteRow(
    _is.DatabaseSession session,
    FilesystemReceipt row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FilesystemReceipt>(
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
  Future<List<FilesystemReceipt>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FilesystemReceiptTable> where,
    _is.OrderByBuilder<FilesystemReceiptTable>? orderBy,
    _is.OrderByListBuilder<FilesystemReceiptTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FilesystemReceipt>(
      where: where(FilesystemReceipt.t),
      orderBy: orderBy?.call(FilesystemReceipt.t),
      orderByList: orderByList?.call(FilesystemReceipt.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FilesystemReceiptTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FilesystemReceipt>(
      where: where?.call(FilesystemReceipt.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FilesystemReceipt] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FilesystemReceiptTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FilesystemReceipt>(
      where: where(FilesystemReceipt.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
