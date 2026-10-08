import 'dart:convert';
import 'dart:io';

import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'verify_demo.dart' show MemoryAuthStorage;

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    throw ArgumentError(
      'Provide the path to the private judge credentials file.',
    );
  }
  final credentials =
      jsonDecode(await File(args.single).readAsString())
          as Map<String, dynamic>;
  final client = Client(credentials['api'] as String);
  final email = credentials['email'] as String;
  final password = credentials['password'] as String;
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  int? temporaryDrive;
  try {
    try {
      await client.emailIdp.login(email: email, password: '$password-invalid');
      throw StateError('Invalid credentials were accepted.');
    } on EmailAccountLoginException catch (error) {
      if (error.reason != EmailAccountLoginExceptionReason.invalidCredentials) {
        rethrow;
      }
    }
    final result = await client.emailIdp.login(
      email: email,
      password: password,
    );
    await auth.updateSignedInUser(result);
    final account = await client.garden.account();
    if (account.email != email) throw StateError('Unexpected judge identity.');
    if ((await client.garden.list()).isNotEmpty) {
      throw StateError('The judge account is no longer a clean account.');
    }
    final drive = await client.garden.create('Judge setup verification');
    temporaryDrive = drive.id;
    final connected = await client.garden.connect(drive.id);
    if (connected.id != drive.id || connected.role != 'Owner') {
      throw StateError('Created drive ownership or connection is incorrect.');
    }
    if (!(await client.garden.list()).any((item) => item.id == drive.id)) {
      throw StateError('The created drive is missing from the account.');
    }
    await client.garden.delete(drive.id);
    temporaryDrive = null;
    if ((await client.garden.list()).isNotEmpty) {
      throw StateError('The verification drive was not removed from the list.');
    }
    await auth.signOutDevice();
    print(
      'Hosted judge account: invalid password rejected, login, clean '
      'membership list, drive creation, owner connection, cleanup and logout passed.',
    );
  } finally {
    if (temporaryDrive != null) await client.garden.delete(temporaryDrive);
    client.close();
  }
}
