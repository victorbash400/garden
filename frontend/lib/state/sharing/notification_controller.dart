import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:garden_client/garden_client.dart';

import '../../services/sharing/drive_sharing_service.dart';
import '../../utils/error_message.dart';

class NotificationController extends ChangeNotifier {
  NotificationController(this.service, {this.onAccessChanged}) {
    service.client.connectivityMonitor?.addListener(_connectivityChanged);
  }
  final DriveSharingService service;
  final void Function()? onAccessChanged;
  final Map<int, AccountNotification> _items = {};
  StreamSubscription<AccountNotification>? _subscription;
  int _generation = 0;
  bool _active = false;
  bool _disconnected = false;
  String? error;
  bool loading = false;
  List<AccountNotification> get items =>
      _items.values.toList()..sort((a, b) => b.id!.compareTo(a.id!));
  int get unread => _items.values.where((item) => item.readAt == null).length;

  Future<void> start() async {
    _active = true;
    final generation = ++_generation;
    final previous = _subscription;
    _subscription = null;
    _items.clear();
    loading = true;
    error = null;
    notifyListeners();
    await previous?.cancel();
    if (generation != _generation) return;
    final connectedAt = DateTime.now().toUtc();
    _subscription = service
        .watch(0)
        .listen(
          (item) {
            if (generation != _generation) return;
            final isNew = !_items.containsKey(item.id!);
            _items[item.id!] = item;
            if (isNew &&
                item.kind == 'accessChanged' &&
                !loading &&
                !item.createdAt.isBefore(connectedAt)) {
              onAccessChanged?.call();
            }
            notifyListeners();
          },
          onError: (Object failure) {
            if (generation != _generation) return;
            error = errorMessage(failure);
            notifyListeners();
          },
          onDone: () {
            if (generation != _generation || !_active) return;
            error ??= 'Notifications disconnected. Refresh to reconnect.';
            notifyListeners();
          },
        );
    try {
      final values = await service.notifications();
      if (generation != _generation) return;
      for (final item in values) {
        _items.putIfAbsent(item.id!, () => item);
      }
    } catch (failure) {
      if (generation == _generation) error = errorMessage(failure);
    } finally {
      if (generation == _generation) {
        loading = false;
        onAccessChanged?.call();
        notifyListeners();
      }
    }
  }

  Future<void> markRead(AccountNotification item) async {
    final generation = _generation;
    await service.markRead(item.id!);
    if (generation != _generation) return;
    _items[item.id!] = item.copyWith(readAt: DateTime.now().toUtc());
    notifyListeners();
  }

  Future<void> reconnectIfNeeded() async {
    if (_active && !loading && error != null) await start();
  }

  Future<void> close() async {
    _active = false;
    _generation++;
    final previous = _subscription;
    _subscription = null;
    _items.clear();
    error = null;
    loading = false;
    await previous?.cancel();
  }

  @override
  void dispose() {
    _active = false;
    service.client.connectivityMonitor?.removeListener(_connectivityChanged);
    _generation++;
    _subscription?.cancel();
    super.dispose();
  }

  void _connectivityChanged(bool connected) {
    if (!connected) {
      _disconnected = true;
    } else if (_active && (_disconnected || error != null)) {
      _disconnected = false;
      unawaited(start());
    }
  }
}
