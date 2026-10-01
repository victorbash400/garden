import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

Future<void> seedDemoAccount(Serverpod pod) async {
  if (pod.runMode != ServerpodRunMode.development) {
    throw StateError('Demo account creation is only allowed in development.');
  }
  final session = await pod.createSession();
  try {
    final auth = AuthServices.instance;
    if (await auth.emailIdp.admin.findAccount(
          session,
          email: 'demo@garden.local',
        ) !=
        null) {
      return;
    }
    await session.db.transaction((transaction) async {
      final user = await auth.authUsers.create(
        session,
        transaction: transaction,
      );
      await auth.emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: user.id,
        email: 'demo@garden.local',
        password: 'garden-demo',
        transaction: transaction,
      );
      await auth.userProfiles.createUserProfile(
        session,
        user.id,
        UserProfileData(email: 'demo@garden.local'),
        transaction: transaction,
      );
    });
    session.log('Garden demo account created.');
  } finally {
    await session.close();
  }
}
