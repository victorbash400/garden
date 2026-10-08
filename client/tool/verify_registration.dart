import 'dart:convert';
import 'dart:io';

import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'verify_demo.dart' show MemoryAuthStorage;

Future<void> main(List<String> args) async {
  if (args.length != 2 || !['begin', 'finish'].contains(args.first)) {
    throw ArgumentError('Provide begin or finish and a private state file.');
  }
  final file = File(args[1]);
  final state = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final email = state['email'] as String;
  final password = state['password'] as String;
  final client = Client(state['api'] as String);
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  int? driveId;
  try {
    if (args.first == 'begin') {
      if (state.containsKey('requestId')) {
        throw StateError('Registration already started for this identity.');
      }
      final requestId = await client.emailIdp.startRegistration(email: email);
      state['requestId'] = requestId.toString();
      await file.writeAsString(jsonEncode(state));
      try {
        await client.emailIdp.login(email: email, password: password);
        throw StateError('An unverified account was allowed to sign in.');
      } on EmailAccountLoginException catch (error) {
        if (error.reason !=
            EmailAccountLoginExceptionReason.invalidCredentials) {
          rethrow;
        }
      }
      print('Registration requested; sign-in before verification rejected.');
      return;
    }
    final token = await client.emailIdp.verifyRegistrationCode(
      accountRequestId: UuidValue.fromString(state['requestId'] as String),
      verificationCode: state['code'] as String,
    );
    final result = await client.emailIdp.finishRegistration(
      registrationToken: token,
      password: password,
    );
    await auth.updateSignedInUser(result);
    if ((await client.garden.account()).email != email) {
      throw StateError('Registered identity does not match.');
    }
    if ((await client.garden.list()).isNotEmpty) {
      throw StateError('The new account already has drives.');
    }
    final drive = await client.garden.create('Signup verification');
    driveId = drive.id;
    final connected = await client.garden.connect(drive.id);
    if (connected.id != drive.id || connected.role != 'Owner') {
      throw StateError('New account drive connection failed.');
    }
    await client.garden.delete(drive.id);
    driveId = null;
    await auth.signOutDevice();
    final login = await client.emailIdp.login(email: email, password: password);
    await auth.updateSignedInUser(login);
    if ((await client.garden.account()).email != email ||
        (await client.garden.list()).isNotEmpty) {
      throw StateError('Sign-in or temporary drive cleanup failed.');
    }
    await auth.signOutDevice();
    state.remove('code');
    state['verified'] = true;
    await file.writeAsString(jsonEncode(state));
    print(
      'Normal email signup, verified identity, clean account, drive creation, '
      'connection, cleanup, logout and repeat sign-in passed.',
    );
  } finally {
    if (driveId != null) await client.garden.delete(driveId);
    client.close();
  }
}
