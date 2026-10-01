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

abstract class GardenRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GardenRecord._({
    this.id,
    required this.name,
    required this.ownerId,
    required this.invitationHash,
    required this.createdAt,
    int? revision,
    bool? deleted,
  }) : revision = revision ?? 0,
       deleted = deleted ?? false;

  factory GardenRecord({
    int? id,
    required String name,
    required String ownerId,
    required String invitationHash,
    required DateTime createdAt,
    int? revision,
    bool? deleted,
  }) = _GardenRecordImpl;

  factory GardenRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return GardenRecord(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      ownerId: jsonSerialization['ownerId'] as String,
      invitationHash: jsonSerialization['invitationHash'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revision: jsonSerialization['revision'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
    );
  }

  static final t = GardenRecordTable();

  static const db = GardenRecordRepository._();

  @override
  int? id;

  String name;

  String ownerId;

  String invitationHash;

  DateTime createdAt;

  int revision;

  bool deleted;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GardenRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GardenRecord copyWith({
    int? id,
    String? name,
    String? ownerId,
    String? invitationHash,
    DateTime? createdAt,
    int? revision,
    bool? deleted,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GardenRecord',
      if (id != null) 'id': id,
      'name': name,
      'ownerId': ownerId,
      'invitationHash': invitationHash,
      'createdAt': createdAt.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GardenRecord',
      if (id != null) 'id': id,
      'name': name,
      'ownerId': ownerId,
      'invitationHash': invitationHash,
      'createdAt': createdAt.toJson(),
      'revision': revision,
      'deleted': deleted,
    };
  }

  static GardenRecordInclude include() {
    return GardenRecordInclude._();
  }

  static GardenRecordIncludeList includeList({
    _is.WhereExpressionBuilder<GardenRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    GardenRecordInclude? include,
  }) {
    return GardenRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GardenRecordImpl extends GardenRecord {
  _GardenRecordImpl({
    int? id,
    required String name,
    required String ownerId,
    required String invitationHash,
    required DateTime createdAt,
    int? revision,
    bool? deleted,
  }) : super._(
         id: id,
         name: name,
         ownerId: ownerId,
         invitationHash: invitationHash,
         createdAt: createdAt,
         revision: revision,
         deleted: deleted,
       );

  /// Returns a shallow copy of this [GardenRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GardenRecord copyWith({
    Object? id = _Undefined,
    String? name,
    String? ownerId,
    String? invitationHash,
    DateTime? createdAt,
    int? revision,
    bool? deleted,
  }) {
    return GardenRecord(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      invitationHash: invitationHash ?? this.invitationHash,
      createdAt: createdAt ?? this.createdAt,
      revision: revision ?? this.revision,
      deleted: deleted ?? this.deleted,
    );
  }
}

class GardenRecordUpdateTable extends _is.UpdateTable<GardenRecordTable> {
  GardenRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> ownerId(String value) => _is.ColumnValue(
    table.ownerId,
    value,
  );

  _is.ColumnValue<String, String> invitationHash(String value) =>
      _is.ColumnValue(
        table.invitationHash,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<bool, bool> deleted(bool value) => _is.ColumnValue(
    table.deleted,
    value,
  );
}

class GardenRecordTable extends _is.Table<int?> {
  GardenRecordTable({super.tableRelation}) : super(tableName: 'garden_record') {
    updateTable = GardenRecordUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    ownerId = _is.ColumnString(
      'ownerId',
      this,
    );
    invitationHash = _is.ColumnString(
      'invitationHash',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
      hasDefault: true,
    );
    deleted = _is.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
  }

  late final GardenRecordUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnString ownerId;

  late final _is.ColumnString invitationHash;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnInt revision;

  late final _is.ColumnBool deleted;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    ownerId,
    invitationHash,
    createdAt,
    revision,
    deleted,
  ];
}

class GardenRecordInclude extends _is.IncludeObject {
  GardenRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GardenRecord.t;
}

class GardenRecordIncludeList extends _is.IncludeList {
  GardenRecordIncludeList._({
    _is.WhereExpressionBuilder<GardenRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GardenRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GardenRecord.t;
}

class GardenRecordRepository {
  const GardenRecordRepository._();

  /// Returns a list of [GardenRecord]s matching the given query parameters.
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
  Future<List<GardenRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GardenRecord>(
      where: where?.call(GardenRecord.t),
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GardenRecord] matching the given query parameters.
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
  Future<GardenRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GardenRecord>(
      where: where?.call(GardenRecord.t),
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GardenRecord] by its [id] or null if no such row exists.
  Future<GardenRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GardenRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GardenRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [GardenRecord]s will have their `id` fields set.
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
  Future<List<GardenRecord>> insert(
    _is.DatabaseSession session,
    List<GardenRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GardenRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GardenRecord] and returns the inserted row.
  ///
  /// The returned [GardenRecord] will have its `id` field set.
  Future<GardenRecord> insertRow(
    _is.DatabaseSession session,
    GardenRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GardenRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GardenRecord]s in the list and returns the resulting rows.
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
  /// The returned [GardenRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenRecord>> upsert(
    _is.DatabaseSession session,
    List<GardenRecord> rows, {
    required _is.ColumnSelections<GardenRecordTable> conflictColumns,
    _is.ColumnSelections<GardenRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<GardenRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GardenRecord>(
      rows,
      conflictColumns: conflictColumns(GardenRecord.t),
      updateColumns: updateColumns?.call(GardenRecord.t),
      updateWhere: updateWhere?.call(GardenRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GardenRecord] and returns the resulting row.
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
  /// The returned [GardenRecord] will have its `id` field set.
  Future<GardenRecord?> upsertRow(
    _is.DatabaseSession session,
    GardenRecord row, {
    required _is.ColumnSelections<GardenRecordTable> conflictColumns,
    _is.ColumnSelections<GardenRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<GardenRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GardenRecord>(
      row,
      conflictColumns: conflictColumns(GardenRecord.t),
      updateColumns: updateColumns?.call(GardenRecord.t),
      updateWhere: updateWhere?.call(GardenRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [GardenRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenRecord>> update(
    _is.DatabaseSession session,
    List<GardenRecord> rows, {
    _is.ColumnSelections<GardenRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GardenRecord>(
      rows,
      columns: columns?.call(GardenRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GardenRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GardenRecord> updateRow(
    _is.DatabaseSession session,
    GardenRecord row, {
    _is.ColumnSelections<GardenRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GardenRecord>(
      row,
      columns: columns?.call(GardenRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GardenRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GardenRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GardenRecordUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GardenRecord>(
      id,
      columnValues: columnValues(GardenRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GardenRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GardenRecordUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GardenRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GardenRecord>(
      columnValues: columnValues(GardenRecord.t.updateTable),
      where: where(GardenRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GardenRecord]s in the list and returns the deleted rows.
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
  Future<List<GardenRecord>> delete(
    _is.DatabaseSession session,
    List<GardenRecord> rows, {
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GardenRecord>(
      rows,
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GardenRecord].
  Future<GardenRecord> deleteRow(
    _is.DatabaseSession session,
    GardenRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GardenRecord>(
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
  Future<List<GardenRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GardenRecordTable> where,
    _is.OrderByBuilder<GardenRecordTable>? orderBy,
    _is.OrderByListBuilder<GardenRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GardenRecord>(
      where: where(GardenRecord.t),
      orderBy: orderBy?.call(GardenRecord.t),
      orderByList: orderByList?.call(GardenRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GardenRecord>(
      where: where?.call(GardenRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GardenRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GardenRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GardenRecord>(
      where: where(GardenRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
