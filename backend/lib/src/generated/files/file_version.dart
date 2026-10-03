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

abstract class FileVersion
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FileVersion._({
    this.id,
    required this.nodeId,
    required this.authorId,
    required this.baseVersion,
    required this.size,
    required this.chunkCount,
    this.objectPath,
    this.uploadId,
    this.partSize,
    bool? committed,
    bool? aborted,
    required this.createdAt,
  }) : committed = committed ?? false,
       aborted = aborted ?? false;

  factory FileVersion({
    int? id,
    required int nodeId,
    required String authorId,
    required int baseVersion,
    required int size,
    required int chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    required DateTime createdAt,
  }) = _FileVersionImpl;

  factory FileVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileVersion(
      id: jsonSerialization['id'] as int?,
      nodeId: jsonSerialization['nodeId'] as int,
      authorId: jsonSerialization['authorId'] as String,
      baseVersion: jsonSerialization['baseVersion'] as int,
      size: jsonSerialization['size'] as int,
      chunkCount: jsonSerialization['chunkCount'] as int,
      objectPath: jsonSerialization['objectPath'] as String?,
      uploadId: jsonSerialization['uploadId'] as String?,
      partSize: jsonSerialization['partSize'] as int?,
      committed: jsonSerialization['committed'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['committed']),
      aborted: jsonSerialization['aborted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['aborted']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = FileVersionTable();

  static const db = FileVersionRepository._();

  @override
  int? id;

  int nodeId;

  String authorId;

  int baseVersion;

  int size;

  int chunkCount;

  String? objectPath;

  String? uploadId;

  int? partSize;

  bool committed;

  bool aborted;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FileVersion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FileVersion copyWith({
    int? id,
    int? nodeId,
    String? authorId,
    int? baseVersion,
    int? size,
    int? chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileVersion',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'baseVersion': baseVersion,
      'size': size,
      'chunkCount': chunkCount,
      if (objectPath != null) 'objectPath': objectPath,
      if (uploadId != null) 'uploadId': uploadId,
      if (partSize != null) 'partSize': partSize,
      'committed': committed,
      'aborted': aborted,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileVersion',
      if (id != null) 'id': id,
      'nodeId': nodeId,
      'authorId': authorId,
      'baseVersion': baseVersion,
      'size': size,
      'chunkCount': chunkCount,
      if (objectPath != null) 'objectPath': objectPath,
      if (uploadId != null) 'uploadId': uploadId,
      if (partSize != null) 'partSize': partSize,
      'committed': committed,
      'aborted': aborted,
      'createdAt': createdAt.toJson(),
    };
  }

  static FileVersionInclude include() {
    return FileVersionInclude._();
  }

  static FileVersionIncludeList includeList({
    _is.WhereExpressionBuilder<FileVersionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    FileVersionInclude? include,
  }) {
    return FileVersionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileVersionImpl extends FileVersion {
  _FileVersionImpl({
    int? id,
    required int nodeId,
    required String authorId,
    required int baseVersion,
    required int size,
    required int chunkCount,
    String? objectPath,
    String? uploadId,
    int? partSize,
    bool? committed,
    bool? aborted,
    required DateTime createdAt,
  }) : super._(
         id: id,
         nodeId: nodeId,
         authorId: authorId,
         baseVersion: baseVersion,
         size: size,
         chunkCount: chunkCount,
         objectPath: objectPath,
         uploadId: uploadId,
         partSize: partSize,
         committed: committed,
         aborted: aborted,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FileVersion]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FileVersion copyWith({
    Object? id = _Undefined,
    int? nodeId,
    String? authorId,
    int? baseVersion,
    int? size,
    int? chunkCount,
    Object? objectPath = _Undefined,
    Object? uploadId = _Undefined,
    Object? partSize = _Undefined,
    bool? committed,
    bool? aborted,
    DateTime? createdAt,
  }) {
    return FileVersion(
      id: id is int? ? id : this.id,
      nodeId: nodeId ?? this.nodeId,
      authorId: authorId ?? this.authorId,
      baseVersion: baseVersion ?? this.baseVersion,
      size: size ?? this.size,
      chunkCount: chunkCount ?? this.chunkCount,
      objectPath: objectPath is String? ? objectPath : this.objectPath,
      uploadId: uploadId is String? ? uploadId : this.uploadId,
      partSize: partSize is int? ? partSize : this.partSize,
      committed: committed ?? this.committed,
      aborted: aborted ?? this.aborted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FileVersionUpdateTable extends _is.UpdateTable<FileVersionTable> {
  FileVersionUpdateTable(super.table);

  _is.ColumnValue<int, int> nodeId(int value) => _is.ColumnValue(
    table.nodeId,
    value,
  );

  _is.ColumnValue<String, String> authorId(String value) => _is.ColumnValue(
    table.authorId,
    value,
  );

  _is.ColumnValue<int, int> baseVersion(int value) => _is.ColumnValue(
    table.baseVersion,
    value,
  );

  _is.ColumnValue<int, int> size(int value) => _is.ColumnValue(
    table.size,
    value,
  );

  _is.ColumnValue<int, int> chunkCount(int value) => _is.ColumnValue(
    table.chunkCount,
    value,
  );

  _is.ColumnValue<String, String> objectPath(String? value) => _is.ColumnValue(
    table.objectPath,
    value,
  );

  _is.ColumnValue<String, String> uploadId(String? value) => _is.ColumnValue(
    table.uploadId,
    value,
  );

  _is.ColumnValue<int, int> partSize(int? value) => _is.ColumnValue(
    table.partSize,
    value,
  );

  _is.ColumnValue<bool, bool> committed(bool value) => _is.ColumnValue(
    table.committed,
    value,
  );

  _is.ColumnValue<bool, bool> aborted(bool value) => _is.ColumnValue(
    table.aborted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class FileVersionTable extends _is.Table<int?> {
  FileVersionTable({super.tableRelation}) : super(tableName: 'file_version') {
    updateTable = FileVersionUpdateTable(this);
    nodeId = _is.ColumnInt(
      'nodeId',
      this,
    );
    authorId = _is.ColumnString(
      'authorId',
      this,
    );
    baseVersion = _is.ColumnInt(
      'baseVersion',
      this,
    );
    size = _is.ColumnInt(
      'size',
      this,
    );
    chunkCount = _is.ColumnInt(
      'chunkCount',
      this,
    );
    objectPath = _is.ColumnString(
      'objectPath',
      this,
    );
    uploadId = _is.ColumnString(
      'uploadId',
      this,
    );
    partSize = _is.ColumnInt(
      'partSize',
      this,
    );
    committed = _is.ColumnBool(
      'committed',
      this,
      hasDefault: true,
    );
    aborted = _is.ColumnBool(
      'aborted',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final FileVersionUpdateTable updateTable;

  late final _is.ColumnInt nodeId;

  late final _is.ColumnString authorId;

  late final _is.ColumnInt baseVersion;

  late final _is.ColumnInt size;

  late final _is.ColumnInt chunkCount;

  late final _is.ColumnString objectPath;

  late final _is.ColumnString uploadId;

  late final _is.ColumnInt partSize;

  late final _is.ColumnBool committed;

  late final _is.ColumnBool aborted;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    nodeId,
    authorId,
    baseVersion,
    size,
    chunkCount,
    objectPath,
    uploadId,
    partSize,
    committed,
    aborted,
    createdAt,
  ];
}

class FileVersionInclude extends _is.IncludeObject {
  FileVersionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FileVersion.t;
}

class FileVersionIncludeList extends _is.IncludeList {
  FileVersionIncludeList._({
    _is.WhereExpressionBuilder<FileVersionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FileVersion.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FileVersion.t;
}

class FileVersionRepository {
  const FileVersionRepository._();

  /// Returns a list of [FileVersion]s matching the given query parameters.
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
  Future<List<FileVersion>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileVersionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FileVersion>(
      where: where?.call(FileVersion.t),
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FileVersion] matching the given query parameters.
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
  Future<FileVersion?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileVersionTable>? where,
    int? offset,
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FileVersion>(
      where: where?.call(FileVersion.t),
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FileVersion] by its [id] or null if no such row exists.
  Future<FileVersion?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FileVersion>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FileVersion]s in the list and returns the inserted rows.
  ///
  /// The returned [FileVersion]s will have their `id` fields set.
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
  Future<List<FileVersion>> insert(
    _is.DatabaseSession session,
    List<FileVersion> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FileVersion>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FileVersion] and returns the inserted row.
  ///
  /// The returned [FileVersion] will have its `id` field set.
  Future<FileVersion> insertRow(
    _is.DatabaseSession session,
    FileVersion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FileVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FileVersion]s in the list and returns the resulting rows.
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
  /// The returned [FileVersion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileVersion>> upsert(
    _is.DatabaseSession session,
    List<FileVersion> rows, {
    required _is.ColumnSelections<FileVersionTable> conflictColumns,
    _is.ColumnSelections<FileVersionTable>? updateColumns,
    _is.WhereExpressionBuilder<FileVersionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FileVersion>(
      rows,
      conflictColumns: conflictColumns(FileVersion.t),
      updateColumns: updateColumns?.call(FileVersion.t),
      updateWhere: updateWhere?.call(FileVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FileVersion] and returns the resulting row.
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
  /// The returned [FileVersion] will have its `id` field set.
  Future<FileVersion?> upsertRow(
    _is.DatabaseSession session,
    FileVersion row, {
    required _is.ColumnSelections<FileVersionTable> conflictColumns,
    _is.ColumnSelections<FileVersionTable>? updateColumns,
    _is.WhereExpressionBuilder<FileVersionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FileVersion>(
      row,
      conflictColumns: conflictColumns(FileVersion.t),
      updateColumns: updateColumns?.call(FileVersion.t),
      updateWhere: updateWhere?.call(FileVersion.t),
      transaction: transaction,
    );
  }

  /// Updates all [FileVersion]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileVersion>> update(
    _is.DatabaseSession session,
    List<FileVersion> rows, {
    _is.ColumnSelections<FileVersionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FileVersion>(
      rows,
      columns: columns?.call(FileVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FileVersion]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FileVersion> updateRow(
    _is.DatabaseSession session,
    FileVersion row, {
    _is.ColumnSelections<FileVersionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FileVersion>(
      row,
      columns: columns?.call(FileVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileVersion] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FileVersion?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FileVersionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FileVersion>(
      id,
      columnValues: columnValues(FileVersion.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FileVersion]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileVersion>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FileVersionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FileVersionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FileVersion>(
      columnValues: columnValues(FileVersion.t.updateTable),
      where: where(FileVersion.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FileVersion]s in the list and returns the deleted rows.
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
  Future<List<FileVersion>> delete(
    _is.DatabaseSession session,
    List<FileVersion> rows, {
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FileVersion>(
      rows,
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FileVersion].
  Future<FileVersion> deleteRow(
    _is.DatabaseSession session,
    FileVersion row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FileVersion>(
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
  Future<List<FileVersion>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileVersionTable> where,
    _is.OrderByBuilder<FileVersionTable>? orderBy,
    _is.OrderByListBuilder<FileVersionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FileVersion>(
      where: where(FileVersion.t),
      orderBy: orderBy?.call(FileVersion.t),
      orderByList: orderByList?.call(FileVersion.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileVersionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FileVersion>(
      where: where?.call(FileVersion.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FileVersion] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileVersionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FileVersion>(
      where: where(FileVersion.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
