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

abstract class DriveMessage
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DriveMessage._({
    this.id,
    required this.gardenId,
    this.conversationId,
    required this.authorId,
    required this.username,
    required this.text,
    this.replyToId,
    this.nodeId,
    this.nodeName,
    bool? hasReplies,
    required this.createdAt,
  }) : hasReplies = hasReplies ?? false;

  factory DriveMessage({
    int? id,
    required int gardenId,
    int? conversationId,
    required String authorId,
    required String username,
    required String text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    required DateTime createdAt,
  }) = _DriveMessageImpl;

  factory DriveMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return DriveMessage(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      conversationId: jsonSerialization['conversationId'] as int?,
      authorId: jsonSerialization['authorId'] as String,
      username: jsonSerialization['username'] as String,
      text: jsonSerialization['text'] as String,
      replyToId: jsonSerialization['replyToId'] as int?,
      nodeId: jsonSerialization['nodeId'] as int?,
      nodeName: jsonSerialization['nodeName'] as String?,
      hasReplies: jsonSerialization['hasReplies'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['hasReplies']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DriveMessageTable();

  static const db = DriveMessageRepository._();

  @override
  int? id;

  int gardenId;

  int? conversationId;

  String authorId;

  String username;

  String text;

  int? replyToId;

  int? nodeId;

  String? nodeName;

  bool hasReplies;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DriveMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DriveMessage copyWith({
    int? id,
    int? gardenId,
    int? conversationId,
    String? authorId,
    String? username,
    String? text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DriveMessage',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'authorId': authorId,
      'username': username,
      'text': text,
      if (replyToId != null) 'replyToId': replyToId,
      if (nodeId != null) 'nodeId': nodeId,
      if (nodeName != null) 'nodeName': nodeName,
      'hasReplies': hasReplies,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DriveMessage',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      if (conversationId != null) 'conversationId': conversationId,
      'authorId': authorId,
      'username': username,
      'text': text,
      if (replyToId != null) 'replyToId': replyToId,
      if (nodeId != null) 'nodeId': nodeId,
      if (nodeName != null) 'nodeName': nodeName,
      'hasReplies': hasReplies,
      'createdAt': createdAt.toJson(),
    };
  }

  static DriveMessageInclude include() {
    return DriveMessageInclude._();
  }

  static DriveMessageIncludeList includeList({
    _is.WhereExpressionBuilder<DriveMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    DriveMessageInclude? include,
  }) {
    return DriveMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DriveMessageImpl extends DriveMessage {
  _DriveMessageImpl({
    int? id,
    required int gardenId,
    int? conversationId,
    required String authorId,
    required String username,
    required String text,
    int? replyToId,
    int? nodeId,
    String? nodeName,
    bool? hasReplies,
    required DateTime createdAt,
  }) : super._(
         id: id,
         gardenId: gardenId,
         conversationId: conversationId,
         authorId: authorId,
         username: username,
         text: text,
         replyToId: replyToId,
         nodeId: nodeId,
         nodeName: nodeName,
         hasReplies: hasReplies,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DriveMessage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DriveMessage copyWith({
    Object? id = _Undefined,
    int? gardenId,
    Object? conversationId = _Undefined,
    String? authorId,
    String? username,
    String? text,
    Object? replyToId = _Undefined,
    Object? nodeId = _Undefined,
    Object? nodeName = _Undefined,
    bool? hasReplies,
    DateTime? createdAt,
  }) {
    return DriveMessage(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      conversationId: conversationId is int?
          ? conversationId
          : this.conversationId,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      text: text ?? this.text,
      replyToId: replyToId is int? ? replyToId : this.replyToId,
      nodeId: nodeId is int? ? nodeId : this.nodeId,
      nodeName: nodeName is String? ? nodeName : this.nodeName,
      hasReplies: hasReplies ?? this.hasReplies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DriveMessageUpdateTable extends _is.UpdateTable<DriveMessageTable> {
  DriveMessageUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<int, int> conversationId(int? value) => _is.ColumnValue(
    table.conversationId,
    value,
  );

  _is.ColumnValue<String, String> authorId(String value) => _is.ColumnValue(
    table.authorId,
    value,
  );

  _is.ColumnValue<String, String> username(String value) => _is.ColumnValue(
    table.username,
    value,
  );

  _is.ColumnValue<String, String> text(String value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<int, int> replyToId(int? value) => _is.ColumnValue(
    table.replyToId,
    value,
  );

  _is.ColumnValue<int, int> nodeId(int? value) => _is.ColumnValue(
    table.nodeId,
    value,
  );

  _is.ColumnValue<String, String> nodeName(String? value) => _is.ColumnValue(
    table.nodeName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class DriveMessageTable extends _is.Table<int?> {
  DriveMessageTable({super.tableRelation}) : super(tableName: 'drive_message') {
    updateTable = DriveMessageUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    conversationId = _is.ColumnInt(
      'conversationId',
      this,
    );
    authorId = _is.ColumnString(
      'authorId',
      this,
    );
    username = _is.ColumnString(
      'username',
      this,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    replyToId = _is.ColumnInt(
      'replyToId',
      this,
    );
    nodeId = _is.ColumnInt(
      'nodeId',
      this,
    );
    nodeName = _is.ColumnString(
      'nodeName',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DriveMessageUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnInt conversationId;

  late final _is.ColumnString authorId;

  late final _is.ColumnString username;

  late final _is.ColumnString text;

  late final _is.ColumnInt replyToId;

  late final _is.ColumnInt nodeId;

  late final _is.ColumnString nodeName;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    conversationId,
    authorId,
    username,
    text,
    replyToId,
    nodeId,
    nodeName,
    createdAt,
  ];
}

class DriveMessageInclude extends _is.IncludeObject {
  DriveMessageInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DriveMessage.t;
}

class DriveMessageIncludeList extends _is.IncludeList {
  DriveMessageIncludeList._({
    _is.WhereExpressionBuilder<DriveMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DriveMessage.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DriveMessage.t;
}

class DriveMessageRepository {
  const DriveMessageRepository._();

  /// Returns a list of [DriveMessage]s matching the given query parameters.
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
  Future<List<DriveMessage>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveMessageTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DriveMessage>(
      where: where?.call(DriveMessage.t),
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DriveMessage] matching the given query parameters.
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
  Future<DriveMessage?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveMessageTable>? where,
    int? offset,
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DriveMessage>(
      where: where?.call(DriveMessage.t),
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DriveMessage] by its [id] or null if no such row exists.
  Future<DriveMessage?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DriveMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DriveMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [DriveMessage]s will have their `id` fields set.
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
  Future<List<DriveMessage>> insert(
    _is.DatabaseSession session,
    List<DriveMessage> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DriveMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DriveMessage] and returns the inserted row.
  ///
  /// The returned [DriveMessage] will have its `id` field set.
  Future<DriveMessage> insertRow(
    _is.DatabaseSession session,
    DriveMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DriveMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DriveMessage]s in the list and returns the resulting rows.
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
  /// The returned [DriveMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveMessage>> upsert(
    _is.DatabaseSession session,
    List<DriveMessage> rows, {
    required _is.ColumnSelections<DriveMessageTable> conflictColumns,
    _is.ColumnSelections<DriveMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveMessageTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DriveMessage>(
      rows,
      conflictColumns: conflictColumns(DriveMessage.t),
      updateColumns: updateColumns?.call(DriveMessage.t),
      updateWhere: updateWhere?.call(DriveMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DriveMessage] and returns the resulting row.
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
  /// The returned [DriveMessage] will have its `id` field set.
  Future<DriveMessage?> upsertRow(
    _is.DatabaseSession session,
    DriveMessage row, {
    required _is.ColumnSelections<DriveMessageTable> conflictColumns,
    _is.ColumnSelections<DriveMessageTable>? updateColumns,
    _is.WhereExpressionBuilder<DriveMessageTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DriveMessage>(
      row,
      conflictColumns: conflictColumns(DriveMessage.t),
      updateColumns: updateColumns?.call(DriveMessage.t),
      updateWhere: updateWhere?.call(DriveMessage.t),
      transaction: transaction,
    );
  }

  /// Updates all [DriveMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveMessage>> update(
    _is.DatabaseSession session,
    List<DriveMessage> rows, {
    _is.ColumnSelections<DriveMessageTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DriveMessage>(
      rows,
      columns: columns?.call(DriveMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DriveMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DriveMessage> updateRow(
    _is.DatabaseSession session,
    DriveMessage row, {
    _is.ColumnSelections<DriveMessageTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DriveMessage>(
      row,
      columns: columns?.call(DriveMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DriveMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DriveMessage?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DriveMessageUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DriveMessage>(
      id,
      columnValues: columnValues(DriveMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DriveMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DriveMessage>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DriveMessageUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DriveMessageTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DriveMessage>(
      columnValues: columnValues(DriveMessage.t.updateTable),
      where: where(DriveMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DriveMessage]s in the list and returns the deleted rows.
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
  Future<List<DriveMessage>> delete(
    _is.DatabaseSession session,
    List<DriveMessage> rows, {
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DriveMessage>(
      rows,
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DriveMessage].
  Future<DriveMessage> deleteRow(
    _is.DatabaseSession session,
    DriveMessage row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DriveMessage>(
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
  Future<List<DriveMessage>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveMessageTable> where,
    _is.OrderByBuilder<DriveMessageTable>? orderBy,
    _is.OrderByListBuilder<DriveMessageTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DriveMessage>(
      where: where(DriveMessage.t),
      orderBy: orderBy?.call(DriveMessage.t),
      orderByList: orderByList?.call(DriveMessage.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DriveMessageTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DriveMessage>(
      where: where?.call(DriveMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DriveMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DriveMessageTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DriveMessage>(
      where: where(DriveMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
