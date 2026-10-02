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
import '../files/file_node.dart' as _iylbd4h6;

abstract class DriveEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DriveEvent._({
    this.id,
    required this.gardenId,
    required this.revision,
    required this.operation,
    required this.authorId,
    this.node,
    this.previousParentId,
    required this.createdAt,
  });

  factory DriveEvent({
    int? id,
    required int gardenId,
    required int revision,
    required String operation,
    required String authorId,
    _iylbd4h6.FileNode? node,
    int? previousParentId,
    required DateTime createdAt,
  }) = _DriveEventImpl;

  factory DriveEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveEvent(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      revision: jsonSerialization['revision'] as int,
      operation: jsonSerialization['operation'] as String,
      authorId: jsonSerialization['authorId'] as String,
      node: jsonSerialization['node'] == null
          ? null
          : _ipujdd36.Protocol().deserialize<_iylbd4h6.FileNode>(
              jsonSerialization['node'],
            ),
      previousParentId: jsonSerialization['previousParentId'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DriveEventTable();

  static const db = DriveEventRepository._();

  @override
  int? id;

  int gardenId;

  int revision;

  String operation;

  String authorId;

  _iylbd4h6.FileNode? node;

  int? previousParentId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DriveEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DriveEvent copyWith({
    int? id,
    int? gardenId,
    int? revision,
    String? operation,
    String? authorId,
    _iylbd4h6.FileNode? node,
    int? previousParentId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveEvent',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'revision': revision,
      'operation': operation,
      'authorId': authorId,
      if (node != null) 'node': node?.toJson(),
      if (previousParentId != null) 'previousParentId': previousParentId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveEvent',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'revision': revision,
      'operation': operation,
      'authorId': authorId,
      if (node != null) 'node': node?.toJsonForProtocol(),
      if (previousParentId != null) 'previousParentId': previousParentId,
      'createdAt': createdAt.toJson(),
    };
  }

  static DriveEventInclude include() {
    return DriveEventInclude._();
  }

  static DriveEventIncludeList includeList({
    _is.WhereExpressionBuilder<DriveEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    DriveEventInclude? include,
  }) {
    return DriveEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveEventImpl extends DriveEvent {
  _DriveEventImpl({
    int? id,
    required int gardenId,
    required int revision,
    required String operation,
    required String authorId,
    _iylbd4h6.FileNode? node,
    int? previousParentId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         revision: revision,
         operation: operation,
         authorId: authorId,
         node: node,
         previousParentId: previousParentId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DriveEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DriveEvent copyWith({
    Object? id = _Undefined,
    int? gardenId,
    int? revision,
    String? operation,
    String? authorId,
    Object? node = _Undefined,
    Object? previousParentId = _Undefined,
    DateTime? createdAt,
  }) {
    return DriveEvent(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      revision: revision ?? this.revision,
      operation: operation ?? this.operation,
      authorId: authorId ?? this.authorId,
      node: node is _iylbd4h6.FileNode? ? node : this.node?.copyWith(),
      previousParentId: previousParentId is int?
          ? previousParentId
          : this.previousParentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DriveEventUpdateTable extends _is.UpdateTable<DriveEventTable> {
  DriveEventUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> operation(String value) => _is.ColumnValue(
    table.operation,
    value,
  );

  _is.ColumnValue<String, String> authorId(String value) => _is.ColumnValue(
    table.authorId,
    value,
  );

  _is.ColumnValue<_iylbd4h6.FileNode, _iylbd4h6.FileNode> node(
    _iylbd4h6.FileNode? value,
  ) => _is.ColumnValue(
    table.node,
    value,
  );

  _is.ColumnValue<int, int> previousParentId(int? value) => _is.ColumnValue(
    table.previousParentId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class DriveEventTable extends _is.Table<int?> {
  DriveEventTable({super.tableRelation}) : super(tableName: 'drive_event') {
    updateTable = DriveEventUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    operation = _is.ColumnString(
      'operation',
      this,
    );
    authorId = _is.ColumnString(
      'authorId',
      this,
    );
    node = _is.ColumnSerializable<_iylbd4h6.FileNode>(
      'node',
      this,
    );
    previousParentId = _is.ColumnInt(
      'previousParentId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DriveEventUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnInt revision;

  late final _is.ColumnString operation;

  late final _is.ColumnString authorId;

  late final _is.ColumnSerializable<_iylbd4h6.FileNode> node;

  late final _is.ColumnInt previousParentId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    revision,
    operation,
    authorId,
    node,
    previousParentId,
    createdAt,
  ];
}

class DriveEventInclude extends _is.IncludeObject {
  DriveEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DriveEvent.t;
}

class DriveEventIncludeList extends _is.IncludeList {
  DriveEventIncludeList._({
    _is.WhereExpressionBuilder<DriveEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DriveEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DriveEvent.t;
}

class DriveEventRepository {
  const DriveEventRepository._();

  /// Returns a list of [DriveEvent]s matching the given query parameters.
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
  Future<List<DriveEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DriveEvent>(
      where: where?.call(DriveEvent.t),
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DriveEvent] matching the given query parameters.
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
  Future<DriveEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveEventTable>? where,
    int? offset,
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DriveEvent>(
      where: where?.call(DriveEvent.t),
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DriveEvent] by its [id] or null if no such row exists.
  Future<DriveEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DriveEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DriveEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [DriveEvent]s will have their `id` fields set.
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
  Future<List<DriveEvent>> insert(
    _is.DatabaseSession session,
    List<DriveEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DriveEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DriveEvent] and returns the inserted row.
  ///
  /// The returned [DriveEvent] will have its `id` field set.
  Future<DriveEvent> insertRow(
    _is.DatabaseSession session,
    DriveEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DriveEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DriveEvent]s in the list and returns the resulting rows.
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
  /// The returned [DriveEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveEvent>> upsert(
    _is.DatabaseSession session,
    List<DriveEvent> rows, {
    required _is.ColumnSelections<DriveEventTable> conflictColumns,
    _is.ColumnSelections<DriveEventTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DriveEvent>(
      rows,
      conflictColumns: conflictColumns(DriveEvent.t),
      updateColumns: updateColumns?.call(DriveEvent.t),
      updateWhere: updateWhere?.call(DriveEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DriveEvent] and returns the resulting row.
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
  /// The returned [DriveEvent] will have its `id` field set.
  Future<DriveEvent?> upsertRow(
    _is.DatabaseSession session,
    DriveEvent row, {
    required _is.ColumnSelections<DriveEventTable> conflictColumns,
    _is.ColumnSelections<DriveEventTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DriveEvent>(
      row,
      conflictColumns: conflictColumns(DriveEvent.t),
      updateColumns: updateColumns?.call(DriveEvent.t),
      updateWhere: updateWhere?.call(DriveEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [DriveEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveEvent>> update(
    _is.DatabaseSession session,
    List<DriveEvent> rows, {
    _is.ColumnSelections<DriveEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DriveEvent>(
      rows,
      columns: columns?.call(DriveEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DriveEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DriveEvent> updateRow(
    _is.DatabaseSession session,
    DriveEvent row, {
    _is.ColumnSelections<DriveEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DriveEvent>(
      row,
      columns: columns?.call(DriveEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DriveEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DriveEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DriveEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DriveEvent>(
      id,
      columnValues: columnValues(DriveEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DriveEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DriveEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DriveEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DriveEvent>(
      columnValues: columnValues(DriveEvent.t.updateTable),
      where: where(DriveEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DriveEvent]s in the list and returns the deleted rows.
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
  Future<List<DriveEvent>> delete(
    _is.DatabaseSession session,
    List<DriveEvent> rows, {
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DriveEvent>(
      rows,
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DriveEvent].
  Future<DriveEvent> deleteRow(
    _is.DatabaseSession session,
    DriveEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DriveEvent>(
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
  Future<List<DriveEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveEventTable> where,
    _is.OrderByBuilder<DriveEventTable>? orderBy,
    _is.OrderByListBuilder<DriveEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DriveEvent>(
      where: where(DriveEvent.t),
      orderBy: orderBy?.call(DriveEvent.t),
      orderByList: orderByList?.call(DriveEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DriveEvent>(
      where: where?.call(DriveEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DriveEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DriveEvent>(
      where: where(DriveEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
