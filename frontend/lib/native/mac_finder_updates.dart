import 'dart:async';
import 'dart:io';

import 'package:garden_client/garden_client.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/serverpod_gateway.dart';
import 'mac_finder_mounts.dart';

class MacFinderUpdates {
  MacFinderUpdates(this.gateway, this.finder, this.onError);

  final ServerpodGateway gateway;
  final MacFinderMounts finder;
  final void Function(Object) onError;
  final Map<int, StreamSubscription<DriveEvent>> _subscriptions = {};

  Future<void> sync(AccountInfo account, List<GardenInfo> drives) async {
    if (!Platform.isMacOS) return;
    final ids = drives.map((drive) => drive.id).toSet();
    for (final id in _subscriptions.keys.toList()) {
      if (!ids.contains(id)) await _subscriptions.remove(id)!.cancel();
    }
    for (final id in ids.difference(_subscriptions.keys.toSet())) {
      final listing = await gateway.client.files.list(id, 0);
      _subscriptions[id] = gateway.client.files.watch(id, listing.revision).listen(
        (event) {
          if (event.operation == 'ready' || event.node == null) return;
          final parents = <int>{event.node!.parentId};
          if (event.previousParentId != null) {
            parents.add(event.previousParentId!);
          }
          unawaited(finder.signal(account, id, parents.toList()).catchError(onError));
        },
        onError: onError,
        onDone: () {
          _subscriptions.remove(id);
          onError(StateError('Finder updates disconnected for drive $id.'));
        },
      );
    }
  }

  Future<void> close() async {
    final subscriptions = _subscriptions.values.toList();
    _subscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
  }
}
