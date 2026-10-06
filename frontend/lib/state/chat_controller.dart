import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../services/chat_gateway.dart';
import '../utils/error_message.dart';

class ChatController extends ChangeNotifier {
  ChatController(this.service, this.driveId, this.userId);
  final ChatService service;
  final int driveId;
  final String userId;
  final Map<int, DriveMessage> _items = {};
  StreamSubscription<DriveMessage>? _stream;
  int _generation = 0;
  int _read = 0;
  int _latestMessageId = 0;
  int _unread = 0;
  Map<String, String> identities = {};
  bool visible = false, loading = false, sending = false, hasOlder = true;
  bool connected = false;
  String? error;
  DriveMessage? thread;
  bool threadHasOlder = false, threadLoading = false;
  int _threadRequest = 0;
  bool historyVisible = false, historyLoading = false, historyHasOlder = true;
  ConversationSummary? conversation;
  final Map<int, ConversationSummary> _conversations = {};
  List<ConversationSummary> get conversations =>
      _conversations.values.toList()
        ..sort((a, b) => b.conversation.id!.compareTo(a.conversation.id!));
  List<DriveMessage> get messages =>
      _items.values.toList()..sort((a, b) => b.id!.compareTo(a.id!));
  int get unread => _unread;

  Future<void> start() async {
    final generation = ++_generation;
    await _stream?.cancel();
    if (generation != _generation) return;
    loading = true;
    connected = false;
    error = null;
    notifyListeners();
    try {
      final snapshot = await service.snapshot(
        driveId,
        conversation: conversation?.conversation.id,
      );
      if (generation != _generation) return;
      final history = snapshot.messages;
      _read = snapshot.readCursor;
      _latestMessageId = snapshot.latestMessageId;
      _unread = snapshot.unreadCount;
      identities = {
        for (final identity in snapshot.identities)
          identity.userId: identity.username,
      };
      for (final item in history) {
        _items[item.id!] = item;
      }
      hasOlder = history.length == 100;
      final cursor = _latestMessageId > 0
          ? _latestMessageId
          : (messages.isEmpty ? 0 : messages.first.id!);
      _stream = service
          .watch(driveId, cursor, conversation: conversation?.conversation.id)
          .listen(
            (item) {
              if (generation != _generation) return;
              if (!_items.containsKey(item.id!) &&
                  item.id! > _read &&
                  item.authorId != userId) {
                _unread++;
              }
              _items[item.id!] = item;
              if (item.id! > _latestMessageId) _latestMessageId = item.id!;
              if (item.replyToId != null) {
                _items[item.replyToId]?.hasReplies = true;
              }
              identities[item.authorId] = item.username;
              connected = true;
              notifyListeners();
              if (visible) unawaited(markRead());
            },
            onError: (Object failure) {
              if (generation != _generation) return;
              connected = false;
              error = errorMessage(failure);
              notifyListeners();
            },
            onDone: () {
              if (generation != _generation) return;
              connected = false;
              error ??= 'Conversation disconnected. Reconnect to continue.';
              notifyListeners();
            },
          );
      connected = true;
      if (visible) await markRead();
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void toggle() {
    visible = !visible;
    notifyListeners();
    if (visible) unawaited(markRead());
  }

  Future<void> markRead() async {
    if (messages.isEmpty && _latestMessageId == 0) return;
    final id = _latestMessageId > (messages.isEmpty ? 0 : messages.first.id!)
        ? _latestMessageId
        : messages.first.id!;
    if (id <= _read) return;
    final generation = _generation;
    try {
      await service.markRead(
        driveId,
        id,
        conversation: conversation?.conversation.id,
      );
      if (generation != _generation) return;
      if (id > _read) {
        _read = id;
        _unread = _items.values
            .where((m) => m.id! > id && m.authorId != userId)
            .length;
      }
      notifyListeners();
    } catch (failure) {
      if (generation == _generation) {
        error = errorMessage(failure);
        notifyListeners();
      }
    }
  }

  Future<void> older() async {
    if (loading || messages.isEmpty) return;
    if (thread != null) {
      final replies = messages.where((m) => m.replyToId == thread!.id).toList();
      if (threadHasOlder && replies.isNotEmpty) {
        await _loadThread(thread!, replies.last.id!);
      }
      return;
    }
    if (!hasOlder) return;
    final generation = _generation;
    loading = true;
    notifyListeners();
    try {
      final values = await service.history(
        driveId,
        messages.where((message) => message.replyToId == null).last.id!,
        conversation: conversation?.conversation.id,
      );
      if (generation != _generation) return;
      for (final value in values) {
        _items[value.id!] = value;
      }
      hasOlder = values.length == 100;
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> send(String text, {int? nodeId}) async {
    if (sending || threadLoading) return false;
    final generation = _generation;
    sending = true;
    error = null;
    notifyListeners();
    try {
      final item = await service.send(
        driveId,
        text,
        thread?.id,
        nodeId,
        conversation: conversation?.conversation.id,
      );
      if (generation != _generation) return false;
      _items[item.id!] = item;
      identities[item.authorId] = item.username;
      if (visible) await markRead();
      return true;
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
      return false;
    } finally {
      if (generation == _generation) {
        sending = false;
        notifyListeners();
      }
    }
  }

  Future<void> openThread(DriveMessage? message) async {
    ++_threadRequest;
    thread = message;
    historyVisible = false;
    threadHasOlder = false;
    threadLoading = message != null;
    notifyListeners();
    if (message != null) await _loadThread(message, 0);
  }

  Future<void> selectConversation(ConversationSummary? selected) async {
    if (sending) return;
    ++_threadRequest;
    conversation = selected;
    thread = null;
    threadLoading = false;
    threadHasOlder = false;
    historyVisible = false;
    _items.clear();
    _read = 0;
    _latestMessageId = 0;
    _unread = 0;
    await start();
  }

  Future<void> createConversation(List<String> recipients, String title) async {
    final generation = _generation;
    final selected = await service.createConversation(
      driveId,
      recipients,
      title,
    );
    if (generation != _generation) return;
    _conversations[selected.conversation.id!] = selected;
    await selectConversation(selected);
  }

  void notifyAudienceChanged() => notifyListeners();

  String audience(String driveName) {
    final selected = conversation;
    if (selected == null) return 'Everyone in $driveName';
    if (selected.conversation.title.isNotEmpty) {
      return selected.conversation.title;
    }
    return selected.members
        .where((member) => member.userId != userId)
        .map((member) => identities[member.userId] ?? member.username)
        .join(', ');
  }

  Future<void> showHistory() async {
    historyVisible = !historyVisible;
    notifyListeners();
    if (historyVisible) await loadConversations();
  }

  Future<void> loadConversations({bool older = false}) async {
    if (historyLoading || (older && !historyHasOlder)) return;
    final generation = _generation;
    final before = older && conversations.isNotEmpty
        ? conversations.last.conversation.id!
        : 0;
    historyLoading = true;
    notifyListeners();
    try {
      final values = await service.conversations(driveId, before);
      if (generation != _generation) return;
      for (final value in values) {
        _conversations[value.conversation.id!] = value;
      }
      historyHasOlder = values.length == 100;
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
    } finally {
      if (generation == _generation) {
        historyLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadThread(DriveMessage message, int before) async {
    final request = ++_threadRequest;
    final generation = _generation;
    threadLoading = true;
    notifyListeners();
    try {
      final values = await service.thread(
        driveId,
        message.id!,
        before,
        conversation: conversation?.conversation.id,
      );
      if (generation != _generation || request != _threadRequest) return;
      if (values.isEmpty) throw StateError('Thread unavailable.');
      thread = values.first;
      threadHasOlder = values.length == 101;
      for (final value in values) {
        _items[value.id!] = value;
      }
      notifyListeners();
    } catch (failure) {
      if (generation == _generation && request == _threadRequest) {
        error = errorMessage(failure);
        notifyListeners();
      }
    } finally {
      if (generation == _generation && request == _threadRequest) {
        threadLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    ++_generation;
    unawaited(_stream?.cancel());
    super.dispose();
  }
}
