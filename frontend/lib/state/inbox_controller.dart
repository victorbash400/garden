import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../services/inbox_service.dart';
import '../services/chat_gateway.dart';
import '../utils/error_message.dart';
import 'chat_controller.dart';

class InboxController extends ChangeNotifier {
  InboxController(this.service, this.messages, this.userId) {
    if (service is ServerpodInboxService) {
      (service as ServerpodInboxService).client.connectivityMonitor
          ?.addListener(_connectivityChanged);
    }
  }
  bool _disconnected = false;
  void _connectivityChanged(bool connected) {
    if (!connected) {
      _disconnected = true;
      return;
    }
    if (_disconnected && _active) {
      _disconnected = false;
      unawaited(start());
    }
  }

  final InboxService service;
  final ChatService messages;
  final String userId;
  List<InboxEntry> entries = [];
  InboxEntry? selected;
  ChatController? chat;
  String? error;
  bool loading = false;
  bool _refreshing = false, _queued = false, _active = false;
  int _generation = 0;
  StreamSubscription<InboxEvent>? _subscription;
  int get unread => entries.fold(
    0,
    (count, entry) =>
        count +
        (entry.unreadCount > 0 ? entry.unreadCount : (entry.isNew ? 1 : 0)),
  );
  static String key(InboxEntry entry) =>
      '${entry.gardenId}:${entry.conversationId ?? 0}';
  String? get selectedKey => chat == null
      ? null
      : '${chat!.driveId}:${chat!.conversation?.conversation.id ?? 0}';
  static String label(InboxEntry entry, String user) => entry.title.isNotEmpty
      ? entry.title
      : entry.conversationId == null
      ? 'Everyone in ${entry.driveName}'
      : entry.members
            .where((member) => member.userId != user)
            .map((member) => member.username)
            .join(', ');

  Future<void> start() async {
    _active = true;
    final generation = ++_generation;
    await _subscription?.cancel();
    if (generation != _generation) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final selection = selectedKey;
      final value = await service.snapshot();
      if (generation != _generation) return;
      _replace(value.entries, selection: selection);
      _subscription = service
          .watch(value.cursor)
          .listen(
            (event) {
              if (generation == _generation) unawaited(refresh());
            },
            onError: (Object failure) {
              if (generation != _generation) return;
              error = errorMessage(failure);
              notifyListeners();
            },
            onDone: () {
              if (generation != _generation || !_active) return;
              error ??= 'Inbox disconnected.';
              notifyListeners();
            },
          );
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
        if (_queued) {
          unawaited(refresh());
        }
      }
    }
  }

  Future<void> refresh() async {
    if (!_active) return;
    if (_refreshing) {
      _queued = true;
      return;
    }
    final generation = _generation;
    _refreshing = true;
    try {
      do {
        _queued = false;
        final selection = selectedKey;
        final value = await service.snapshot();
        if (generation != _generation) return;
        _replace(value.entries, selection: selection);
        error = null;
        notifyListeners();
      } while (_queued && generation == _generation);
    } catch (failure) {
      if (generation == _generation) {
        error = errorMessage(failure);
        notifyListeners();
      }
    } finally {
      _refreshing = false;
    }
  }

  void _replace(List<InboxEntry> values, {String? selection}) {
    entries = values
      ..sort(
        (a, b) => (b.latestAt ?? b.createdAt ?? DateTime.utc(1970)).compareTo(
          a.latestAt ?? a.createdAt ?? DateTime.utc(1970),
        ),
      );
    if (chat != null) {
      final current = entries.where((entry) => key(entry) == selectedKey);
      if (current.isEmpty) {
        if (selection == selectedKey) {
          clearSelection();
        } else {
          _queued = true;
        }
      } else {
        selected = current.first;
        if (chat!.conversation != null) {
          chat!.conversation!.conversation.title = selected!.title;
          chat!.conversation!.members = selected!.members;
        }
      }
    }
  }

  Future<void> select(InboxEntry entry) async {
    if (selectedKey == key(entry)) {
      chat!.visible = true;
      notifyListeners();
      return;
    }
    clearSelection();
    selected = entry;
    final current = ChatController(messages, entry.gardenId, userId)
      ..visible = true;
    if (entry.conversationId != null) {
      current.conversation = ConversationSummary(
        conversation: Conversation(
          id: entry.conversationId,
          gardenId: entry.gardenId,
          title: entry.title,
          creatorId: entry.creatorId!,
          createdAt: entry.createdAt!,
        ),
        members: entry.members,
      );
    }
    chat = current;
    current.addListener(_chatChanged);
    notifyListeners();
    await current.start();
    if (entry.isNew && entry.unreadCount == 0 && entry.conversationId != null) {
      try {
        await service.seen(entry.conversationId!);
      } catch (failure) {
        error = errorMessage(failure);
        notifyListeners();
      }
    }
  }

  void _chatChanged() {
    final current = entries.where((entry) => key(entry) == selectedKey);
    if (current.isNotEmpty) selected = current.first;
    notifyListeners();
  }

  void clearSelection() {
    chat?.removeListener(_chatChanged);
    chat?.dispose();
    chat = null;
    selected = null;
  }

  Future<void> reconnectIfNeeded() async {
    if (_active && !loading && error != null) await start();
    if (chat != null && !chat!.connected && !chat!.loading) await chat!.start();
  }

  Future<void> close() async {
    _active = false;
    ++_generation;
    clearSelection();
    entries = [];
    await _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    if (service is ServerpodInboxService) {
      (service as ServerpodInboxService).client.connectivityMonitor
          ?.removeListener(_connectivityChanged);
    }
    _active = false;
    ++_generation;
    _subscription?.cancel();
    clearSelection();
    super.dispose();
  }
}
