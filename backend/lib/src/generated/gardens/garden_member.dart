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

abstract class GardenMember
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  GardenMember._({
    this.id,
    required this.gardenId,
    required this.userId,
    required this.role,
  });

  factory GardenMember({
    int? id,
    required int gardenId,
    required String userId,
    required String role,
  }) = _GardenMemberImpl;

  factory GardenMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return GardenMember(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      userId: jsonSerialization['userId'] as String,
      role: jsonSerialization['role'] as String,
    );
  }

  static final t = GardenMemberTable();

  static const db = GardenMemberRepository._();

  @override
  int? id;

  int gardenId;

  String userId;

  String role;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [GardenMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  GardenMember copyWith({
    int? id,
    int? gardenId,
    String? userId,
    String? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'GardenMember',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'role': role,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'GardenMember',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'role': role,
    };
  }

  static GardenMemberInclude include() {
    return GardenMemberInclude._();
  }

  static GardenMemberIncludeList includeList({
    _is.WhereExpressionBuilder<GardenMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    GardenMemberInclude? include,
  }) {
    return GardenMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _GardenMemberImpl extends GardenMember {
  _GardenMemberImpl({
    int? id,
    required int gardenId,
    required String userId,
    required String role,
  }) : super._(
         id: id,
         gardenId: gardenId,
         userId: userId,
         role: role,
       );

  /// Returns a shallow copy of this [GardenMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  GardenMember copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? userId,
    String? role,
  }) {
    return GardenMember(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }
}

class GardenMemberUpdateTable extends _is.UpdateTable<GardenMemberTable> {
  GardenMemberUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
    table.role,
    value,
  );
}

class GardenMemberTable extends _is.Table<int?> {
  GardenMemberTable({super.tableRelation}) : super(tableName: 'garden_member') {
    updateTable = GardenMemberUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
    );
  }

  late final GardenMemberUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnString userId;

  late final _is.ColumnString role;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    userId,
    role,
  ];
}

class GardenMemberInclude extends _is.IncludeObject {
  GardenMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => GardenMember.t;
}

class GardenMemberIncludeList extends _is.IncludeList {
  GardenMemberIncludeList._({
    _is.WhereExpressionBuilder<GardenMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(GardenMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => GardenMember.t;
}

class GardenMemberRepository {
  const GardenMemberRepository._();

  /// Returns a list of [GardenMember]s matching the given query parameters.
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
  Future<List<GardenMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<GardenMember>(
      where: where?.call(GardenMember.t),
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [GardenMember] matching the given query parameters.
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
  Future<GardenMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<GardenMember>(
      where: where?.call(GardenMember.t),
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [GardenMember] by its [id] or null if no such row exists.
  Future<GardenMember?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<GardenMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [GardenMember]s in the list and returns the inserted rows.
  ///
  /// The returned [GardenMember]s will have their `id` fields set.
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
  Future<List<GardenMember>> insert(
    _is.DatabaseSession session,
    List<GardenMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<GardenMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [GardenMember] and returns the inserted row.
  ///
  /// The returned [GardenMember] will have its `id` field set.
  Future<GardenMember> insertRow(
    _is.DatabaseSession session,
    GardenMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<GardenMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [GardenMember]s in the list and returns the resulting rows.
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
  /// The returned [GardenMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenMember>> upsert(
    _is.DatabaseSession session,
    List<GardenMember> rows, {
    required _is.ColumnSelections<GardenMemberTable> conflictColumns,
    _is.ColumnSelections<GardenMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<GardenMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<GardenMember>(
      rows,
      conflictColumns: conflictColumns(GardenMember.t),
      updateColumns: updateColumns?.call(GardenMember.t),
      updateWhere: updateWhere?.call(GardenMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [GardenMember] and returns the resulting row.
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
  /// The returned [GardenMember] will have its `id` field set.
  Future<GardenMember?> upsertRow(
    _is.DatabaseSession session,
    GardenMember row, {
    required _is.ColumnSelections<GardenMemberTable> conflictColumns,
    _is.ColumnSelections<GardenMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<GardenMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<GardenMember>(
      row,
      conflictColumns: conflictColumns(GardenMember.t),
      updateColumns: updateColumns?.call(GardenMember.t),
      updateWhere: updateWhere?.call(GardenMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [GardenMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenMember>> update(
    _is.DatabaseSession session,
    List<GardenMember> rows, {
    _is.ColumnSelections<GardenMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<GardenMember>(
      rows,
      columns: columns?.call(GardenMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [GardenMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<GardenMember> updateRow(
    _is.DatabaseSession session,
    GardenMember row, {
    _is.ColumnSelections<GardenMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<GardenMember>(
      row,
      columns: columns?.call(GardenMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [GardenMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<GardenMember?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<GardenMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<GardenMember>(
      id,
      columnValues: columnValues(GardenMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [GardenMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<GardenMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<GardenMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<GardenMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<GardenMember>(
      columnValues: columnValues(GardenMember.t.updateTable),
      where: where(GardenMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [GardenMember]s in the list and returns the deleted rows.
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
  Future<List<GardenMember>> delete(
    _is.DatabaseSession session,
    List<GardenMember> rows, {
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<GardenMember>(
      rows,
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [GardenMember].
  Future<GardenMember> deleteRow(
    _is.DatabaseSession session,
    GardenMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<GardenMember>(
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
  Future<List<GardenMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GardenMemberTable> where,
    _is.OrderByBuilder<GardenMemberTable>? orderBy,
    _is.OrderByListBuilder<GardenMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<GardenMember>(
      where: where(GardenMember.t),
      orderBy: orderBy?.call(GardenMember.t),
      orderByList: orderByList?.call(GardenMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<GardenMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<GardenMember>(
      where: where?.call(GardenMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [GardenMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<GardenMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<GardenMember>(
      where: where(GardenMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
