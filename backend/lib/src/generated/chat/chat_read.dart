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

abstract class ChatRead
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ChatRead._({
    this.id,
    required this.gardenId,
    required this.userId,
    required this.messageId,
  });

  factory ChatRead({
    int? id,
    required int gardenId,
    required String userId,
    required int messageId,
  }) = _ChatReadImpl;

  factory ChatRead.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatRead(
      id: jsonSerialization['id'] as int?,
      gardenId: jsonSerialization['gardenId'] as int,
      userId: jsonSerialization['userId'] as String,
      messageId: jsonSerialization['messageId'] as int,
    );
  }

  static final t = ChatReadTable();

  static const db = ChatReadRepository._();

  @override
  int? id;

  int gardenId;

  String userId;

  int messageId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ChatRead]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ChatRead copyWith({
    int? id,
    int? gardenId,
    String? userId,
    int? messageId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatRead',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'messageId': messageId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChatRead',
      if (id != null) 'id': id,
      'gardenId': gardenId,
      'userId': userId,
      'messageId': messageId,
    };
  }

  static ChatReadInclude include() {
    return ChatReadInclude._();
  }

  static ChatReadIncludeList includeList({
    _is.WhereExpressionBuilder<ChatReadTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    ChatReadInclude? include,
  }) {
    return ChatReadIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatReadImpl extends ChatRead {
  _ChatReadImpl({
    int? id,
    required int gardenId,
    required String userId,
    required int messageId,
  }) : super._(
         id: id,
         gardenId: gardenId,
         userId: userId,
         messageId: messageId,
       );

  /// Returns a shallow copy of this [ChatRead]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ChatRead copyWith({
    Object? id = _Undefined,
    int? gardenId,
    String? userId,
    int? messageId,
  }) {
    return ChatRead(
      id: id is int? ? id : this.id,
      gardenId: gardenId ?? this.gardenId,
      userId: userId ?? this.userId,
      messageId: messageId ?? this.messageId,
    );
  }
}

class ChatReadUpdateTable extends _is.UpdateTable<ChatReadTable> {
  ChatReadUpdateTable(super.table);

  _is.ColumnValue<int, int> gardenId(int value) => _is.ColumnValue(
    table.gardenId,
    value,
  );

  _is.ColumnValue<String, String> userId(String value) => _is.ColumnValue(
    table.userId,
    value,
  );

  _is.ColumnValue<int, int> messageId(int value) => _is.ColumnValue(
    table.messageId,
    value,
  );
}

class ChatReadTable extends _is.Table<int?> {
  ChatReadTable({super.tableRelation}) : super(tableName: 'chat_read') {
    updateTable = ChatReadUpdateTable(this);
    gardenId = _is.ColumnInt(
      'gardenId',
      this,
    );
    userId = _is.ColumnString(
      'userId',
      this,
    );
    messageId = _is.ColumnInt(
      'messageId',
      this,
    );
  }

  late final ChatReadUpdateTable updateTable;

  late final _is.ColumnInt gardenId;

  late final _is.ColumnString userId;

  late final _is.ColumnInt messageId;

  @override
  List<_is.Column> get columns => [
    id,
    gardenId,
    userId,
    messageId,
  ];
}

class ChatReadInclude extends _is.IncludeObject {
  ChatReadInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ChatRead.t;
}

class ChatReadIncludeList extends _is.IncludeList {
  ChatReadIncludeList._({
    _is.WhereExpressionBuilder<ChatReadTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ChatRead.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ChatRead.t;
}

class ChatReadRepository {
  const ChatReadRepository._();

  /// Returns a list of [ChatRead]s matching the given query parameters.
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
  Future<List<ChatRead>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatReadTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ChatRead>(
      where: where?.call(ChatRead.t),
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ChatRead] matching the given query parameters.
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
  Future<ChatRead?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatReadTable>? where,
    int? offset,
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ChatRead>(
      where: where?.call(ChatRead.t),
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ChatRead] by its [id] or null if no such row exists.
  Future<ChatRead?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ChatRead>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ChatRead]s in the list and returns the inserted rows.
  ///
  /// The returned [ChatRead]s will have their `id` fields set.
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
  Future<List<ChatRead>> insert(
    _is.DatabaseSession session,
    List<ChatRead> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ChatRead>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ChatRead] and returns the inserted row.
  ///
  /// The returned [ChatRead] will have its `id` field set.
  Future<ChatRead> insertRow(
    _is.DatabaseSession session,
    ChatRead row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ChatRead>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ChatRead]s in the list and returns the resulting rows.
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
  /// The returned [ChatRead]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatRead>> upsert(
    _is.DatabaseSession session,
    List<ChatRead> rows, {
    required _is.ColumnSelections<ChatReadTable> conflictColumns,
    _is.ColumnSelections<ChatReadTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatReadTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ChatRead>(
      rows,
      conflictColumns: conflictColumns(ChatRead.t),
      updateColumns: updateColumns?.call(ChatRead.t),
      updateWhere: updateWhere?.call(ChatRead.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ChatRead] and returns the resulting row.
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
  /// The returned [ChatRead] will have its `id` field set.
  Future<ChatRead?> upsertRow(
    _is.DatabaseSession session,
    ChatRead row, {
    required _is.ColumnSelections<ChatReadTable> conflictColumns,
    _is.ColumnSelections<ChatReadTable>? updateColumns,
    _is.WhereExpressionBuilder<ChatReadTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ChatRead>(
      row,
      conflictColumns: conflictColumns(ChatRead.t),
      updateColumns: updateColumns?.call(ChatRead.t),
      updateWhere: updateWhere?.call(ChatRead.t),
      transaction: transaction,
    );
  }

  /// Updates all [ChatRead]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatRead>> update(
    _is.DatabaseSession session,
    List<ChatRead> rows, {
    _is.ColumnSelections<ChatReadTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ChatRead>(
      rows,
      columns: columns?.call(ChatRead.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ChatRead]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ChatRead> updateRow(
    _is.DatabaseSession session,
    ChatRead row, {
    _is.ColumnSelections<ChatReadTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ChatRead>(
      row,
      columns: columns?.call(ChatRead.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ChatRead] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ChatRead?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChatReadUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ChatRead>(
      id,
      columnValues: columnValues(ChatRead.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ChatRead]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ChatRead>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChatReadUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ChatReadTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ChatRead>(
      columnValues: columnValues(ChatRead.t.updateTable),
      where: where(ChatRead.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ChatRead]s in the list and returns the deleted rows.
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
  Future<List<ChatRead>> delete(
    _is.DatabaseSession session,
    List<ChatRead> rows, {
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ChatRead>(
      rows,
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ChatRead].
  Future<ChatRead> deleteRow(
    _is.DatabaseSession session,
    ChatRead row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ChatRead>(
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
  Future<List<ChatRead>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatReadTable> where,
    _is.OrderByBuilder<ChatReadTable>? orderBy,
    _is.OrderByListBuilder<ChatReadTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ChatRead>(
      where: where(ChatRead.t),
      orderBy: orderBy?.call(ChatRead.t),
      orderByList: orderByList?.call(ChatRead.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChatReadTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ChatRead>(
      where: where?.call(ChatRead.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ChatRead] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChatReadTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ChatRead>(
      where: where(ChatRead.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
