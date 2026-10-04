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
import '../files/node_kind.dart' as _iiiid2sw;

abstract class FileNode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  FileNode._({
    this.id,
    required this.gardenId,
    required this.parentId,
    required this.name,
    this.activeName,
    required this.kind,
    int? size,
    int? version,
    bool? deleted,
    required this.updatedAt,
    this.createdAt,
  }) : size = size ?? 0,
       version = version ?? 0,
       deleted = deleted ?? false;

  factory FileNode({
    int? id,
    required int gardenId,
    required int parentId,
    required String name,
    String? activeName,
    required _iiiid2sw.NodeKind kind,
    int? size,
    int? version,
    bool? deleted,
    required DateTime updatedAt,
    DateTime? createdAt,
  }) = _FileNodeImpl;

  factory FileNode.fromJson(Map<String, dynamic> jsonSerialization) {
    return FileNode(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      parentId: jsonSerialization['parentId'] as int,
      name: jsonSerialization['name'] as String,
      activeName: jsonSerialization['activeName'] as String?,
      kind: _iiiid2sw.NodeKind.fromJson((jsonSerialization['kind'] as String)),
      size: jsonSerialization['size'] as int?,
      version: jsonSerialization['version'] as int?,
      deleted: jsonSerialization['deleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['deleted']),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = FileNodeTable();

  static const db = FileNodeRepository._();

  @override
  int? id;

  int gardenId;

  int parentId;

  String name;

  String? activeName;

  _iiiid2sw.NodeKind kind;

  int size;

  int version;

  bool deleted;

  DateTime updatedAt;

  DateTime? createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [FileNode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  FileNode copyWith({
    int? id,
    int? gardenId,
    int? parentId,
    String? name,
    String? activeName,
    _iiiid2sw.NodeKind? kind,
    int? size,
    int? version,
    bool? deleted,
    DateTime? updatedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FileNode',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'parentId': parentId,
      'name': name,
      if (activeName != null) 'activeName': activeName,
      'kind': kind.toJson(),
      'size': size,
      'version': version,
      'deleted': deleted,
      'updatedAt': updatedAt.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FileNode',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'parentId': parentId,
      'name': name,
      if (activeName != null) 'activeName': activeName,
      'kind': kind.toJson(),
      'size': size,
      'version': version,
      'deleted': deleted,
      'updatedAt': updatedAt.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static FileNodeInclude include() {
    return FileNodeInclude._();
  }

  static FileNodeIncludeList includeList({
    _is.WhereExpressionBuilder<FileNodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    FileNodeInclude? include,
  }) {
    return FileNodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FileNodeImpl extends FileNode {
  _FileNodeImpl({
    int? id,
    required int gardenId,
    required int parentId,
    required String name,
    String? activeName,
    required _iiiid2sw.NodeKind kind,
    int? size,
    int? version,
    bool? deleted,
    required DateTime updatedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         parentId: parentId,
         name: name,
         activeName: activeName,
         kind: kind,
         size: size,
         version: version,
         deleted: deleted,
         updatedAt: updatedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [FileNode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  FileNode copyWith({
    Object? id = _Undefined,
    int? gardenId,
    int? parentId,
    String? name,
    Object? activeName = _Undefined,
    _iiiid2sw.NodeKind? kind,
    int? size,
    int? version,
    bool? deleted,
    DateTime? updatedAt,
    Object? createdAt = _Undefined,
  }) {
    return FileNode(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      activeName: activeName is String? ? activeName : this.activeName,
      kind: kind ?? this.kind,
      size: size ?? this.size,
      version: version ?? this.version,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class FileNodeUpdateTable extends _is.UpdateTable<FileNodeTable> {
  FileNodeUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<int, int> parentId(int value) => _is.ColumnValue(
    table.parentId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> activeName(String? value) => _is.ColumnValue(
    table.activeName,
    value,
  );

  _is.ColumnValue<_iiiid2sw.NodeKind, _iiiid2sw.NodeKind> kind(
    _iiiid2sw.NodeKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> size(int value) => _is.ColumnValue(
    table.size,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<bool, bool> deleted(bool value) => _is.ColumnValue(
    table.deleted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class FileNodeTable extends _is.Table<int?> {
  FileNodeTable({super.tableRelation}) : super(tableName: 'file_node') {
    updateTable = FileNodeUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    parentId = _is.ColumnInt(
      'parentId',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    activeName = _is.ColumnString(
      'activeName',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    size = _is.ColumnInt(
      'size',
      this,
      hasDefault: true,
    );
    version = _is.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    deleted = _is.ColumnBool(
      'deleted',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final FileNodeUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnInt parentId;

  late final _is.ColumnString name;

  late final _is.ColumnString activeName;

  late final _is.ColumnEnum<_iiiid2sw.NodeKind> kind;

  late final _is.ColumnInt size;

  late final _is.ColumnInt version;

  late final _is.ColumnBool deleted;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    parentId,
    name,
    activeName,
    kind,
    size,
    version,
    deleted,
    updatedAt,
    createdAt,
  ];
}

class FileNodeInclude extends _is.IncludeObject {
  FileNodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => FileNode.t;
}

class FileNodeIncludeList extends _is.IncludeList {
  FileNodeIncludeList._({
    _is.WhereExpressionBuilder<FileNodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FileNode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => FileNode.t;
}

class FileNodeRepository {
  const FileNodeRepository._();

  /// Returns a list of [FileNode]s matching the given query parameters.
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
  Future<List<FileNode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileNodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FileNode>(
      where: where?.call(FileNode.t),
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FileNode] matching the given query parameters.
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
  Future<FileNode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileNodeTable>? where,
    int? offset,
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FileNode>(
      where: where?.call(FileNode.t),
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FileNode] by its [id] or null if no such row exists.
  Future<FileNode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FileNode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FileNode]s in the list and returns the inserted rows.
  ///
  /// The returned [FileNode]s will have their `id` fields set.
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
  Future<List<FileNode>> insert(
    _is.DatabaseSession session,
    List<FileNode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<FileNode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [FileNode] and returns the inserted row.
  ///
  /// The returned [FileNode] will have its `id` field set.
  Future<FileNode> insertRow(
    _is.DatabaseSession session,
    FileNode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<FileNode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [FileNode]s in the list and returns the resulting rows.
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
  /// The returned [FileNode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileNode>> upsert(
    _is.DatabaseSession session,
    List<FileNode> rows, {
    required _is.ColumnSelections<FileNodeTable> conflictColumns,
    _is.ColumnSelections<FileNodeTable>? updateColumns,
    _is.WhereExpressionBuilder<FileNodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<FileNode>(
      rows,
      conflictColumns: conflictColumns(FileNode.t),
      updateColumns: updateColumns?.call(FileNode.t),
      updateWhere: updateWhere?.call(FileNode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [FileNode] and returns the resulting row.
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
  /// The returned [FileNode] will have its `id` field set.
  Future<FileNode?> upsertRow(
    _is.DatabaseSession session,
    FileNode row, {
    required _is.ColumnSelections<FileNodeTable> conflictColumns,
    _is.ColumnSelections<FileNodeTable>? updateColumns,
    _is.WhereExpressionBuilder<FileNodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<FileNode>(
      row,
      conflictColumns: conflictColumns(FileNode.t),
      updateColumns: updateColumns?.call(FileNode.t),
      updateWhere: updateWhere?.call(FileNode.t),
      transaction: transaction,
    );
  }

  /// Updates all [FileNode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileNode>> update(
    _is.DatabaseSession session,
    List<FileNode> rows, {
    _is.ColumnSelections<FileNodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<FileNode>(
      rows,
      columns: columns?.call(FileNode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [FileNode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FileNode> updateRow(
    _is.DatabaseSession session,
    FileNode row, {
    _is.ColumnSelections<FileNodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<FileNode>(
      row,
      columns: columns?.call(FileNode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FileNode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FileNode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<FileNodeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<FileNode>(
      id,
      columnValues: columnValues(FileNode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FileNode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<FileNode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<FileNodeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<FileNodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<FileNode>(
      columnValues: columnValues(FileNode.t.updateTable),
      where: where(FileNode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [FileNode]s in the list and returns the deleted rows.
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
  Future<List<FileNode>> delete(
    _is.DatabaseSession session,
    List<FileNode> rows, {
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<FileNode>(
      rows,
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [FileNode].
  Future<FileNode> deleteRow(
    _is.DatabaseSession session,
    FileNode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FileNode>(
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
  Future<List<FileNode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileNodeTable> where,
    _is.OrderByBuilder<FileNodeTable>? orderBy,
    _is.OrderByListBuilder<FileNodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<FileNode>(
      where: where(FileNode.t),
      orderBy: orderBy?.call(FileNode.t),
      orderByList: orderByList?.call(FileNode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<FileNodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<FileNode>(
      where: where?.call(FileNode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FileNode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<FileNodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FileNode>(
      where: where(FileNode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
