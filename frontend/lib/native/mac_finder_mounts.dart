import 'dart:io';

import 'package:flutter/services.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/serverpod_gateway.dart';
import 'finder_mounts.dart';

class MacFinderMounts implements FinderMounts {
  MacFinderMounts(this.gateway, this.serverURL);

  final ServerpodGateway gateway;
  final String serverURL;
  static const _channel = MethodChannel('garden/finder');
  @override
  final Set<int> mountedDriveIDs = {};

  @override
  Future<void> sync(AccountInfo account, List<GardenInfo> drives) async {
    if (!Platform.isMacOS) return;
    final ids = drives.map((drive) => drive.id).toList();
    final missing = await _channel.invokeListMethod<int>('missing', {
      'accountID': account.id,
      'driveIDs': ids,
    });
    if (missing == null) {
      throw StateError('Finder did not return drive status.');
    }
    for (final drive in drives.where((drive) => missing.contains(drive.id))) {
      final session = await gateway.client.garden.finderSession(drive.id);
      await _channel.invokeMethod<void>('register', {
        'accountID': account.id,
        'driveID': drive.id,
        'name': drive.name,
        'serverURL': serverURL,
        'token': session.token,
        'tokenID': session.tokenId,
        'refreshToken': session.refreshToken,
      });
    }
    await _channel.invokeMethod<void>('reconcile', {
      'accountID': account.id,
      'driveIDs': ids,
    });
    mountedDriveIDs
      ..clear()
      ..addAll(ids);
  }

  @override
  Future<void> signOut(AccountInfo account) async {
    if (!Platform.isMacOS) return;
    final ids = await _channel.invokeListMethod<String>('tokenIDs', {
      'accountID': account.id,
    });
    if (ids == null) throw StateError('Finder did not return session IDs.');
    await gateway.client.garden.revokeFinderSessions(ids);
    await _channel.invokeMethod<void>('signOut', {'accountID': account.id});
    mountedDriveIDs.clear();
  }

  @override
  Future<Set<int>> enabled(AccountInfo account, List<GardenInfo> drives) async {
    if (!Platform.isMacOS) return {};
    final ids = await _channel.invokeListMethod<int>('enabled', {
      'accountID': account.id,
      'driveIDs': drives.map((drive) => drive.id).toList(),
    });
    if (ids == null) throw StateError('Finder did not return drive status.');
    return ids.toSet();
  }

  @override
  Future<void> open(AccountInfo account, int driveID) async {
    if (!Platform.isMacOS) return;
    await _channel.invokeMethod<void>('open', {
      'accountID': account.id,
      'driveID': driveID,
    });
  }

  @override
  Future<void> openSettings() async {
    if (!Platform.isMacOS) return;
    await _channel.invokeMethod<void>('openSettings');
  }

  @override
  Future<void> signal(
    AccountInfo account,
    int driveID,
    List<int> parentIDs,
  ) async {
    if (!Platform.isMacOS) return;
    await _channel.invokeMethod<void>('signal', {
      'accountID': account.id,
      'driveID': driveID,
      'parentIDs': parentIDs,
    });
  }
}
