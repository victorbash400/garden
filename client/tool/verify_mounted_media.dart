import 'dart:convert';
import 'dart:io';

import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'verify_demo.dart' show MemoryAuthStorage;

Future<void> main(List<String> args) async {
  if (args.length != 3) {
    throw ArgumentError(
      'Provide private credentials, drive ID and fixture directory.',
    );
  }
  final credentials =
      jsonDecode(await File(args[0]).readAsString()) as Map<String, dynamic>;
  final driveId = int.parse(args[1]);
  final client = Client(credentials['api'] as String);
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  try {
    await auth.updateSignedInUser(
      await client.emailIdp.login(
        email: credentials['email'] as String,
        password: credentials['password'] as String,
      ),
    );
    final nodes = (await client.files.list(driveId, 0)).nodes;
    for (final fixture in await Directory(args[2]).list().toList()) {
      if (fixture is! File) continue;
      final name = fixture.uri.pathSegments.last;
      final node = nodes.singleWhere((node) => node.name == name);
      final expected = await fixture.readAsBytes();
      final data = await client.content.read(
        node.id!,
        node.version,
        0,
        node.size,
      );
      final actual = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      if (actual.length != expected.length || node.size != expected.length) {
        throw StateError('Cloud size mismatch for $name.');
      }
      for (var index = 0; index < expected.length; index++) {
        if (actual[index] != expected[index])
          throw StateError('Cloud content mismatch for $name.');
      }
      print(
        '$name: independent cloud download matched ${actual.length} bytes.',
      );
    }
    await auth.signOutDevice();
  } finally {
    client.close();
  }
}
