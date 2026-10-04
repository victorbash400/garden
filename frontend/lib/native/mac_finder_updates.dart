import 'dart:async';

import 'package:flutter/services.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../utils/error_message.dart';
import 'finder_status.dart';
import 'finder_updates.dart';

class MacFinderUpdates extends FinderUpdates {
  MacFinderUpdates({
    Stream<FinderStatus> Function(AccountInfo, List<GardenInfo>)? watch,
  }) : _watch = watch ?? _nativeUpdates;

  final Stream<FinderStatus> Function(AccountInfo, List<GardenInfo>) _watch;
  StreamSubscription<FinderStatus>? _subscription;
  FinderUpdateState _state = FinderUpdateState.idle;
  int _generation = 0;
  @override
  String? error;
  @override
  FinderStatus? status;
  @override
  FinderUpdateState get state => _state;

  static Stream<FinderStatus> _nativeUpdates(
    AccountInfo account,
    List<GardenInfo> drives,
  ) => const EventChannel('garden/finder/updates')
      .receiveBroadcastStream({
        'accountID': account.id,
        'driveIDs': drives.map((drive) => drive.id).toList(),
      })
      .map((value) {
        if (value is! Map) {
          throw const FormatException('Invalid native drive status.');
        }
        return FinderStatus.fromMap(value.cast<Object?, Object?>());
      });

  @override
  Future<void> sync(AccountInfo account, List<GardenInfo> drives) async {
    await close();
    if (drives.isEmpty) return;
    final generation = _generation;
    final ids = drives.map((drive) => drive.id).toSet();
    _state = FinderUpdateState.connecting;
    notifyListeners();
    _subscription = _watch(account, drives).listen(
      (status) {
        if (generation != _generation) return;
        this.status = status;
        error = status.enabled.containsAll(ids)
            ? null
            : 'Finder drives disconnected.';
        _state = error == null
            ? FinderUpdateState.running
            : FinderUpdateState.disconnected;
        notifyListeners();
      },
      onError: (Object failure) {
        if (generation != _generation) return;
        _failure(failure);
      },
      onDone: () {
        if (generation != _generation) return;
        _failure(StateError('Drive status connection closed.'));
      },
      cancelOnError: true,
    );
  }

  void _failure(Object failure) {
    error = errorMessage(failure);
    final registered = status?.registered;
    if (registered != null) {
      status = FinderStatus(registered: registered, disconnected: registered);
    }
    _state = FinderUpdateState.disconnected;
    notifyListeners();
  }

  @override
  Future<void> close() async {
    _generation++;
    await _subscription?.cancel();
    _subscription = null;
    error = null;
    _state = FinderUpdateState.idle;
    status = null;
    notifyListeners();
  }
}
