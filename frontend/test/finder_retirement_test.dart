import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_client/garden_client.dart';
import 'package:garden_flutter/model/account_info.dart';
import 'package:garden_flutter/model/garden_info.dart';
import 'package:garden_flutter/native/mac_finder_mounts.dart';
import 'package:garden_flutter/native/mac_finder_updates.dart';
import 'package:garden_flutter/native/finder_status.dart';
import 'package:garden_flutter/services/serverpod_gateway.dart';
import 'package:garden_flutter/state/garden_controller.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'widget_test.dart' show MemoryPreferences, TestFinder, TestGateway;

class BusyRetirementFinder extends TestFinder {
  bool busy = true;
  @override
  Future<void> signOut(AccountInfo account) async {
    if (busy) throw StateError('File is open');
    await super.signOut(account);
  }
}

class RetirementClient extends Client {
  RetirementClient(this.events) : super('https://unused.invalid/');
  final List<String> events;
  bool failRevocation = false;

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) async {
    expect(endpoint, 'garden');
    expect(method, 'revokeFinderSessions');
    expect(args['tokenIds'], ['finder-one']);
    events.add('revoke');
    if (failRevocation) throw StateError('Cloud unavailable');
    return null as T;
  }
}

class RetirementGateway extends ServerpodGateway {
  RetirementGateway(this.testClient) : super('https://unused.invalid/');
  final RetirementClient testClient;
  @override
  Client get client => testClient;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('garden/finder');
  const account = AccountInfo(id: 'account-one', email: 'test@example.invalid');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> events;
  late RetirementClient client;
  late MacFinderMounts mounts;
  bool failPrepare = false;
  bool failFinalize = false;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    events = [];
    client = RetirementClient(events);
    mounts = MacFinderMounts(
      RetirementGateway(client),
      'https://unused.invalid/',
    );
    mounts.mountedDriveIDs.addAll([1, 2]);
    failPrepare = false;
    failFinalize = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      events.add(call.method);
      expect((call.arguments as Map)['accountID'], account.id);
      if (call.method == 'missing') return <int>[];
      if (call.method == 'prepareRemoval') {
        if (failPrepare) {
          throw PlatformException(code: 'busy', message: 'File is open');
        }
        return ['finder-one'];
      }
      if (failFinalize) {
        throw PlatformException(code: 'save', message: 'Registry unavailable');
      }
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('rejected sign-out keeps the account and drive status stream', () async {
    var cancelled = false;
    final stream = StreamController<FinderStatus>(
      onCancel: () => cancelled = true,
    );
    final updates = MacFinderUpdates(watch: (_, _) => stream.stream);
    final finder = BusyRetirementFinder();
    final controller = GardenController(
      TestGateway(),
      MemoryPreferences(),
      finder: finder,
      finderUpdates: updates,
    )..account = account;
    await updates.sync(account, [
      const GardenInfo(id: 1, name: 'Drive', role: 'owner', members: 1),
    ]);
    await controller.signOut();
    expect(controller.account, account);
    expect(controller.error, contains('File is open'));
    expect(cancelled, isFalse);
    finder.busy = false;
    await controller.signOut();
    expect(controller.account, isNull);
    expect(cancelled, isTrue);
    controller.dispose();
    await stream.close();
  });

  test(
    'sign-out prepares drives before revocation and final removal',
    () async {
      await mounts.signOut(account);
      expect(events, ['prepareRemoval', 'revoke', 'signOut']);
      expect(mounts.mountedDriveIDs, isEmpty);
    },
    skip: !Platform.isMacOS,
  );

  test('busy drive rejects sign-out before any token revocation', () async {
    failPrepare = true;
    await expectLater(
      mounts.signOut(account),
      throwsA(isA<PlatformException>()),
    );
    expect(events, ['prepareRemoval']);
    expect(mounts.mountedDriveIDs, {1, 2});
  }, skip: !Platform.isMacOS);

  test(
    'failed revocation leaves native removal unfinished and can retry',
    () async {
      client.failRevocation = true;
      await expectLater(mounts.signOut(account), throwsStateError);
      expect(events, ['prepareRemoval', 'revoke']);
      expect(mounts.mountedDriveIDs, {1, 2});
      client.failRevocation = false;
      await mounts.signOut(account);
      expect(events, [
        'prepareRemoval',
        'revoke',
        'prepareRemoval',
        'revoke',
        'signOut',
      ]);
      expect(mounts.mountedDriveIDs, isEmpty);
    },
    skip: !Platform.isMacOS,
  );

  test('failed finalization keeps sign-out retryable', () async {
    failFinalize = true;
    await expectLater(
      mounts.signOut(account),
      throwsA(isA<PlatformException>()),
    );
    expect(mounts.mountedDriveIDs, {1, 2});
    failFinalize = false;
    await mounts.signOut(account);
    expect(events, [
      'prepareRemoval',
      'revoke',
      'signOut',
      'prepareRemoval',
      'revoke',
      'signOut',
    ]);
    expect(mounts.mountedDriveIDs, isEmpty);
  }, skip: !Platform.isMacOS);

  test(
    'drive reconciliation uses the same preparation before revocation',
    () async {
      await mounts.sync(account, [
        const GardenInfo(id: 2, name: 'Kept', role: 'owner', members: 1),
      ]);
      expect(events, ['missing', 'rename', 'prepareRemoval', 'revoke', 'reconcile']);
      expect(mounts.mountedDriveIDs, {2});
    },
    skip: !Platform.isMacOS,
  );
}
