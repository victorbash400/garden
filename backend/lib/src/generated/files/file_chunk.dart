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

abstract class FileChunk
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FileChunk._({
    this.id,
    required this.versionId,
    required this.chunkIndex,
    required this.size,
    required this.checksum,
  });

  factory FileChunk({
    int? id,
    required int versionId,
    required int chunkIndex,
    required int size,
    required String checksum,
  }) = _FileChunkImpl;

  factory FileChunk.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileChunk(
      id: jsonSerialization['id'] as int?,
      versionId: jsonSerialization['versionId'] as int,
      chunkIndex: jsonSerialization['chunkIndex'] as int,
      size: jsonSerialization['size'] as int,
      checksum: jsonSerialization['checksum'] as String,
    );
  }

  static final t = FileChunkTable();

  static const db = FileChunkRepository._();

  @override
  int? id;

  int versionId;

  int chunkIndex;

  int size;

  String checksum;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FileChunk]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FileChunk copyWith({
    int? id,
    int? versionId,
    int? chunkIndex,
    int? size,
    String? checksum,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileChunk',
      if (id != null) 'id': id,
      'versionId': versionId,
      'chunkIndex': chunkIndex,
      'size': size,
      'checksum': checksum,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileChunk',
      if (id != null) 'id': id,
      'versionId': versionId,
      'chunkIndex': chunkIndex,
      'size': size,
      'checksum': checksum,
    };
  }

  static FileChunkInclude include() {
    return FileChunkInclude._();
  }

  static FileChunkIncludeList includeList({
    _is.WhereExpressionBuilder<FileChunkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    FileChunkInclude? include,
  }) {
    return FileChunkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileChunkImpl extends FileChunk {
  _FileChunkImpl({
    int? id,
    required int versionId,
    required int chunkIndex,
    required int size,
    required String checksum,
  }) : super._(
         id: id,
         versionId: versionId,
         chunkIndex: chunkIndex,
         size: size,
         checksum: checksum,
       );

  /// Returns a shallow copy of this [FileChunk]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FileChunk copyWith({
    Object? id = _Undefined,
    int? versionId,
    int? chunkIndex,
    int? size,
    String? checksum,
  }) {
    return FileChunk(
      id: id is int? ? id : this.id,
      versionId: versionId ?? this.versionId,
      chunkIndex: chunkIndex ?? this.chunkIndex,
      size: size ?? this.size,
      checksum: checksum ?? this.checksum,
    );
  }
}

class FileChunkUpdateTable extends _is.UpdateTable<FileChunkTable> {
  FileChunkUpdateTable(super.table);

  _is.ColumnValue<int, int> versionId(int value) => _is.ColumnValue(
    table.versionId,
    value,
  );

  _is.ColumnValue<int, int> chunkIndex(int value) => _is.ColumnValue(
    table.chunkIndex,
    value,
  );

  _is.ColumnValue<int, int> size(int value) => _is.ColumnValue(
    table.size,
    value,
  );

  _is.ColumnValue<String, String> checksum(String value) => _is.ColumnValue(
    table.checksum,
    value,
  );
}

class FileChunkTable extends _is.Table<int?> {
  FileChunkTable({super.tableRelation}) : super(tableName: 'file_chunk') {
    updateTable = FileChunkUpdateTable(this);
    versionId = _is.ColumnInt(
      'versionId',
      this,
    );
    chunkIndex = _is.ColumnInt(
      'chunkIndex',
      this,
    );
    size = _is.ColumnInt(
      'size',
      this,
    );
    checksum = _is.ColumnString(
      'checksum',
      this,
    );
  }

  late final FileChunkUpdateTable updateTable;

  late final _is.ColumnInt versionId;

  late final _is.ColumnInt chunkIndex;

  late final _is.ColumnInt size;

  late final _is.ColumnString checksum;

  @override
  List<_is.Column> get columns => [
    id,
    versionId,
    chunkIndex,
    size,
    checksum,
  ];
}

class FileChunkInclude extends _is.IncludeObject {
  FileChunkInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FileChunk.t;
}

class FileChunkIncludeList extends _is.IncludeList {
  FileChunkIncludeList._({
    _is.WhereExpressionBuilder<FileChunkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FileChunk.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FileChunk.t;
}

class FileChunkRepository {
  const FileChunkRepository._();

  /// Returns a list of [FileChunk]s matching the given query parameters.
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
  Future<List<FileChunk>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileChunkTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FileChunk>(
      where: where?.call(FileChunk.t),
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FileChunk] matching the given query parameters.
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
  Future<FileChunk?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileChunkTable>? where,
    int? offset,
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FileChunk>(
      where: where?.call(FileChunk.t),
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FileChunk] by its [id] or null if no such row exists.
  Future<FileChunk?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FileChunk>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FileChunk]s in the list and returns the inserted rows.
  ///
  /// The returned [FileChunk]s will have their `id` fields set.
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
  Future<List<FileChunk>> insert(
    _is.DatabaseSession session,
    List<FileChunk> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FileChunk>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FileChunk] and returns the inserted row.
  ///
  /// The returned [FileChunk] will have its `id` field set.
  Future<FileChunk> insertRow(
    _is.DatabaseSession session,
    FileChunk row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FileChunk>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FileChunk]s in the list and returns the resulting rows.
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
  /// The returned [FileChunk]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileChunk>> upsert(
    _is.DatabaseSession session,
    List<FileChunk> rows, {
    required _is.ColumnSelections<FileChunkTable> conflictColumns,
    _is.ColumnSelections<FileChunkTable>? updateColumns,
    _is.WhereExpressionBuilder<FileChunkTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FileChunk>(
      rows,
      conflictColumns: conflictColumns(FileChunk.t),
      updateColumns: updateColumns?.call(FileChunk.t),
      updateWhere: updateWhere?.call(FileChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FileChunk] and returns the resulting row.
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
  /// The returned [FileChunk] will have its `id` field set.
  Future<FileChunk?> upsertRow(
    _is.DatabaseSession session,
    FileChunk row, {
    required _is.ColumnSelections<FileChunkTable> conflictColumns,
    _is.ColumnSelections<FileChunkTable>? updateColumns,
    _is.WhereExpressionBuilder<FileChunkTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FileChunk>(
      row,
      conflictColumns: conflictColumns(FileChunk.t),
      updateColumns: updateColumns?.call(FileChunk.t),
      updateWhere: updateWhere?.call(FileChunk.t),
      transaction: transaction,
    );
  }

  /// Updates all [FileChunk]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileChunk>> update(
    _is.DatabaseSession session,
    List<FileChunk> rows, {
    _is.ColumnSelections<FileChunkTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FileChunk>(
      rows,
      columns: columns?.call(FileChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FileChunk]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FileChunk> updateRow(
    _is.DatabaseSession session,
    FileChunk row, {
    _is.ColumnSelections<FileChunkTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FileChunk>(
      row,
      columns: columns?.call(FileChunk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileChunk] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FileChunk?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FileChunkUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FileChunk>(
      id,
      columnValues: columnValues(FileChunk.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FileChunk]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileChunk>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FileChunkUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FileChunkTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FileChunk>(
      columnValues: columnValues(FileChunk.t.updateTable),
      where: where(FileChunk.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FileChunk]s in the list and returns the deleted rows.
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
  Future<List<FileChunk>> delete(
    _is.DatabaseSession session,
    List<FileChunk> rows, {
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FileChunk>(
      rows,
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FileChunk].
  Future<FileChunk> deleteRow(
    _is.DatabaseSession session,
    FileChunk row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FileChunk>(
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
  Future<List<FileChunk>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileChunkTable> where,
    _is.OrderByBuilder<FileChunkTable>? orderBy,
    _is.OrderByListBuilder<FileChunkTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FileChunk>(
      where: where(FileChunk.t),
      orderBy: orderBy?.call(FileChunk.t),
      orderByList: orderByList?.call(FileChunk.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileChunkTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FileChunk>(
      where: where?.call(FileChunk.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FileChunk] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileChunkTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FileChunk>(
      where: where(FileChunk.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
