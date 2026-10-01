import 'dart:io';
import 'src/auth/demo_account.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/generated/serverpod.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      // The default setup works with Serverpod Cloud without configuration. In
      // development the verification codes are logged to the console, and in
      // staging and production they are sent through the Serverpod Cloud email
      // service. If you want to use a custom provider for sending emails, use
      // `EmailIdpConfigFromPasswords`.
      ServerpodCloudEmailIdpConfig(
        appDisplayName: 'garden',
      ),
    ],
  );

  if (pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test) {
    pod.addCloudStorage(DatabaseCloudStorage('private'));
  } else {
    pod.addCloudStorage(
      await ServerpodCloudProvider.private(
        fallback: () => throw StateError(
          'Serverpod Cloud private storage is not configured.',
        ),
      ),
    );
  }

  // Start the server.
  await pod.start();
  if (Platform.environment['GARDEN_SEED_DEMO'] == 'true') {
    await seedDemoAccount(pod);
  }
}
