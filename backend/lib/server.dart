import 'dart:io';
import 'package:serverpod_auth_idp_server/providers/passkey.dart';
import 'src/auth/app_association_route.dart';
import 'src/auth/demo_account.dart';
import 'src/auth/garden_email_config.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'src/files/file_storage.dart';
import 'src/files/upload_cleanup_tasks.dart';

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
      gardenEmailConfig(pod),
      const PasskeyIdpConfig(hostname: 'garden.serverpod.space'),
    ],
  );

  pod.webServer.addRoute(
    AppAssociationRoute(),
    '/.well-known/apple-app-site-association',
  );
  await configureFileStorage(pod);
  await UploadCleanupTasks.configure(pod);

  // Start the server.
  await pod.start();
  if (Platform.environment['GARDEN_SEED_DEMO'] == 'true') {
    await seedDemoAccount(pod);
  }
}
