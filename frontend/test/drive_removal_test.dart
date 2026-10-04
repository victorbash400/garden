import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/state/garden_controller.dart';

import 'widget_test.dart' show MemoryPreferences, TestFinder, TestGateway;

class RemovalFinder extends TestFinder {
  RemovalFinder(this.events);
  final List<String> events;
  bool fail = false;
  Completer<void>? wait;
  final entered = Completer<void>();

  @override
  Future<void> sync(AccountInfo account, List<GardenInfo> drives) async {
    events.add('sync:${drives.map((drive) => drive.id).join(',')}');
    if (!entered.isCompleted) entered.complete();
    await wait?.future;
    if (fail) throw StateError('Pending edits could not be published.');
    await super.sync(account, drives);
  }

  @override
  Future<void> signOut(AccountInfo account) async {
    events.add('signOut');
    if (!entered.isCompleted) entered.complete();
    await wait?.future;
    await super.signOut(account);
  }
}

class RemovalGateway extends TestGateway {
  RemovalGateway(this.events);
  final List<String> events;
  bool failDelete = false;

  @override
  Future<void> deleteDrive(int driveId) async {
    events.add('delete:$driveId');
    if (failDelete) throw StateError('Cloud unavailable.');
  }
}

void main() {
  const account = AccountInfo(id: 'account', email: 'test@example.invalid');
  const removed = GardenInfo(id: 1, name: 'Removed', role: 'Owner', members: 1);
  const kept = GardenInfo(id: 2, name: 'Kept', role: 'Owner', members: 1);
  late List<String> events;
  late RemovalFinder finder;
  late RemovalGateway gateway;
  late GardenController controller;

  setUp(() {
    events = [];
    finder = RemovalFinder(events)..mountedDriveIDs.addAll([1, 2]);
    gateway = RemovalGateway(events);
    controller = GardenController(gateway, MemoryPreferences(), finder: finder)
      ..account = account
      ..gardens = [removed, kept];
  });
  tearDown(() async {
    await controller.handleSystemWake();
    controller.dispose();
  });

  test(
    'pending-edit failure prevents cloud deletion and preserves the list',
    () async {
      finder.fail = true;
      await controller.deleteDrive(removed);
      expect(events, ['sync:2']);
      expect(controller.gardens, [removed, kept]);
      expect(finder.mountedDriveIDs, {1, 2});
      expect(controller.error, contains('Pending edits'));
    },
  );

  test('cloud deletion follows native cleanup and remains retryable', () async {
    gateway.failDelete = true;
    await controller.deleteDrive(removed);
    expect(events, ['sync:2', 'delete:1']);
    expect(controller.gardens, [removed, kept]);
    expect(finder.mountedDriveIDs, {2});
    expect(controller.error, contains('Cloud unavailable'));
    gateway.failDelete = false;
    await controller.deleteDrive(removed);
    expect(controller.gardens, [kept]);
    expect(events.take(4), ['sync:2', 'delete:1', 'sync:2', 'delete:1']);
  });

  test('wake cannot remount the drive during deletion', () async {
    finder.wait = Completer<void>();
    final removal = controller.deleteDrive(removed);
    await finder.entered.future;
    await controller.handleSystemWake();
    expect(events, ['sync:2']);
    finder.wait!.complete();
    await removal;
    expect(controller.gardens, [kept]);
    expect(events.take(2), ['sync:2', 'delete:1']);
    expect(events, isNot(contains('sync:1,2')));
  });

  test('wake cannot remount drives during sign-out', () async {
    finder.wait = Completer<void>();
    final signOut = controller.signOut();
    await finder.entered.future;
    await controller.handleSystemWake();
    expect(events, ['signOut']);
    finder.wait!.complete();
    await signOut;
    expect(controller.account, isNull);
    expect(events, ['signOut']);
  });

  test('non-owner deletion never changes mount access', () async {
    await controller.deleteDrive(
      const GardenInfo(id: 1, name: 'Shared', role: 'Member', members: 2),
    );
    expect(events, isEmpty);
    expect(controller.error, contains('Only the drive owner'));
    expect(finder.mountedDriveIDs, {1, 2});
  });
}
