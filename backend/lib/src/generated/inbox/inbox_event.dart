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

abstract class InboxEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  InboxEvent._({
    this.id,
    required this.userId,
    required this.gardenId,
    this.conversationId,
    required this.kind,
    required this.createdAt,
  });

  factory InboxEvent({
    int? id,
    required String userId,
    required int gardenId,
    int? conversationId,
    required String kind,
    required DateTime createdAt,
  }) = _InboxEventImpl;

  factory InboxEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return InboxEvent(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as String,
      gardenId: jsonSerialization['gardenId'] as int,
      conversationId: jsonSerialization['conversationId'] as int?,
      kind: jsonSerialization['kind'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = InboxEventTable();

  static const db = InboxEventRepository._();

  @override
  int? id;

  String userId;

  int gardenId;

  int? conversationId;

  String kind;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [InboxEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  InboxEvent copyWith({
    int? id,
    String? userId,
    int? gardenId,
    int? conversationId,
    String? kind,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InboxEvent',
      if (id != null) 'id': id,
      'userId': userId,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'kind': kind,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InboxEvent',
      if (id != null) 'id': id,
      'userId': userId,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'kind': kind,
      'createdAt': createdAt.toJson(),
    };
  }

  static InboxEventInclude include() {
    return InboxEventInclude._();
  }

  static InboxEventIncludeList includeList({
    _is.WhereExpressionBuilder<InboxEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    InboxEventInclude? include,
  }) {
    return InboxEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InboxEventImpl extends InboxEvent {
  _InboxEventImpl({
    int? id,
    required String userId,
    required int gardenId,
    int? conversationId,
    required String kind,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         gardenId: gardenId,
         conversationId: conversationId,
         kind: kind,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [InboxEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  InboxEvent copyWith({
    Object? id = _Undefined,
    String? userId,
    int? gardenId,
    Object? conversationId = _Undefined,
    String? kind,
    DateTime? createdAt,
  }) {
    return InboxEvent(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      gardenId: gardenId ?? this.gardenId,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class InboxEventUpdateTable extends _is.UpdateTable<InboxEventTable> {
  InboxEventUpdateTable(super.table);

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<int, int> conversationId(int? value) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class InboxEventTable extends _is.Table<int?> {
  InboxEventTable({super.tableRelation}) : super(tableName: 'inbox_event') {
    updateTable = InboxEventUpdateTable(this);
    userId = _is.ColumnString(
      'userId',
      this,
    );
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    conversationId = _is.ColumnInt(
      'conversationId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final InboxEventUpdateTable updateTable;

  late final _is.ColumnString userId;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnInt conversationId;

  late final _is.ColumnString kind;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    userId,
    gardenId,
    conversationId,
    kind,
    createdAt,
  ];
}

class InboxEventInclude extends _is.IncludeObject {
  InboxEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => InboxEvent.t;
}

class InboxEventIncludeList extends _is.IncludeList {
  InboxEventIncludeList._({
    _is.WhereExpressionBuilder<InboxEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InboxEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => InboxEvent.t;
}

class InboxEventRepository {
  const InboxEventRepository._();

  /// Returns a list of [InboxEvent]s matching the given query parameters.
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
  Future<List<InboxEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InboxEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InboxEvent>(
      where: where?.call(InboxEvent.t),
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [InboxEvent] matching the given query parameters.
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
  Future<InboxEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InboxEventTable>? where,
    int? offset,
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InboxEvent>(
      where: where?.call(InboxEvent.t),
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InboxEvent] by its [id] or null if no such row exists.
  Future<InboxEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InboxEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InboxEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [InboxEvent]s will have their `id` fields set.
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
  Future<List<InboxEvent>> insert(
    _is.DatabaseSession session,
    List<InboxEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<InboxEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [InboxEvent] and returns the inserted row.
  ///
  /// The returned [InboxEvent] will have its `id` field set.
  Future<InboxEvent> insertRow(
    _is.DatabaseSession session,
    InboxEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<InboxEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [InboxEvent]s in the list and returns the resulting rows.
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
  /// The returned [InboxEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InboxEvent>> upsert(
    _is.DatabaseSession session,
    List<InboxEvent> rows, {
    required _is.ColumnSelections<InboxEventTable> conflictColumns,
    _is.ColumnSelections<InboxEventTable>? updateColumns,
    _is.WhereExpressionBuilder<InboxEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<InboxEvent>(
      rows,
      conflictColumns: conflictColumns(InboxEvent.t),
      updateColumns: updateColumns?.call(InboxEvent.t),
      updateWhere: updateWhere?.call(InboxEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [InboxEvent] and returns the resulting row.
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
  /// The returned [InboxEvent] will have its `id` field set.
  Future<InboxEvent?> upsertRow(
    _is.DatabaseSession session,
    InboxEvent row, {
    required _is.ColumnSelections<InboxEventTable> conflictColumns,
    _is.ColumnSelections<InboxEventTable>? updateColumns,
    _is.WhereExpressionBuilder<InboxEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<InboxEvent>(
      row,
      conflictColumns: conflictColumns(InboxEvent.t),
      updateColumns: updateColumns?.call(InboxEvent.t),
      updateWhere: updateWhere?.call(InboxEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [InboxEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InboxEvent>> update(
    _is.DatabaseSession session,
    List<InboxEvent> rows, {
    _is.ColumnSelections<InboxEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<InboxEvent>(
      rows,
      columns: columns?.call(InboxEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [InboxEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InboxEvent> updateRow(
    _is.DatabaseSession session,
    InboxEvent row, {
    _is.ColumnSelections<InboxEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<InboxEvent>(
      row,
      columns: columns?.call(InboxEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InboxEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InboxEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<InboxEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<InboxEvent>(
      id,
      columnValues: columnValues(InboxEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InboxEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<InboxEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<InboxEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<InboxEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<InboxEvent>(
      columnValues: columnValues(InboxEvent.t.updateTable),
      where: where(InboxEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [InboxEvent]s in the list and returns the deleted rows.
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
  Future<List<InboxEvent>> delete(
    _is.DatabaseSession session,
    List<InboxEvent> rows, {
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<InboxEvent>(
      rows,
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [InboxEvent].
  Future<InboxEvent> deleteRow(
    _is.DatabaseSession session,
    InboxEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InboxEvent>(
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
  Future<List<InboxEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InboxEventTable> where,
    _is.OrderByBuilder<InboxEventTable>? orderBy,
    _is.OrderByListBuilder<InboxEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<InboxEvent>(
      where: where(InboxEvent.t),
      orderBy: orderBy?.call(InboxEvent.t),
      orderByList: orderByList?.call(InboxEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<InboxEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<InboxEvent>(
      where: where?.call(InboxEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InboxEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<InboxEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InboxEvent>(
      where: where(InboxEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
