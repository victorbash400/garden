import 'dart:async';

import 'package:garden_client/garden_client.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/files/files_gateway.dart';
import '../utils/error_message.dart';
import 'finder_mounts.dart';
import 'finder_updates.dart';
import 'system_setup.dart';

class MacFinderUpdates extends FinderUpdates {
  MacFinderUpdates(this.gateway, this.finder, this.system);
  final FilesGateway gateway;
  final FinderMounts finder;
  final SystemSetup system;
  final Map<int, StreamSubscription<DriveEvent>> _subscriptions = {};
  final Set<int> _ready = {};
  Set<int> _expected = {};
  @override
  String? error;
  int _generation = 0;

  @override
  FinderUpdateState get state => error != null
      ? FinderUpdateState.disconnected
      : _expected.isEmpty
      ? FinderUpdateState.idle
      : _ready.containsAll(_expected)
      ? FinderUpdateState.running
      : FinderUpdateState.connecting;

  @override
  Future<void> sync(AccountInfo account, List<GardenInfo> drives) async {
    final generation = _generation;
    _expected = drives.map((drive) => drive.id).toSet();
    error = null;
    notifyListeners();
    try {
      await system.setBackgroundActive(_expected.isNotEmpty);
      for (final id in _subscriptions.keys.toList()) {
        if (!_expected.contains(id)) {
          _ready.remove(id);
          await _subscriptions.remove(id)!.cancel();
        }
      }
      for (final id in _expected.difference(_subscriptions.keys.toSet())) {
        final listing = await gateway.list(id, 0);
        if (generation != _generation) return;
        _subscriptions[id] = gateway
            .watch(id, listing.revision)
            .listen(
              (event) {
                if (generation != _generation) return;
                if (event.operation == 'ready') {
                  _ready.add(id);
                  notifyListeners();
                  unawaited(
                    finder.signal(account, id, [0]).catchError((
                      Object failure,
                    ) {
                      if (generation == _generation) _failure(failure);
                    }),
                  );
                  return;
                }
                final node = event.node;
                if (node == null) return;
                final parents = <int>{node.parentId};
                if (event.previousParentId != null) {
                  parents.add(event.previousParentId!);
                }
                unawaited(
                  finder.signal(account, id, parents.toList()).catchError((
                    Object failure,
                  ) {
                    if (generation == _generation) _failure(failure);
                  }),
                );
              },
              onError: (Object failure) {
                if (generation != _generation) return;
                _subscriptions.remove(id);
                _ready.remove(id);
                _failure(failure);
              },
              onDone: () {
                if (generation != _generation || !_expected.contains(id)) {
                  return;
                }
                _subscriptions.remove(id);
                _ready.remove(id);
                _failure(StateError('Finder live updates disconnected.'));
              },
              cancelOnError: true,
            );
      }
      notifyListeners();
    } catch (failure) {
      _failure(failure);
      rethrow;
    }
  }

  void _failure(Object failure) {
    error = errorMessage(failure);
    notifyListeners();
  }

  @override
  Future<void> close() async {
    _generation++;
    _expected = {};
    _ready.clear();
    final subscriptions = _subscriptions.values.toList();
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await system.setBackgroundActive(false);
    error = null;
    notifyListeners();
  }
}
