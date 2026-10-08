import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

Future<void> seedDemoAccount(Serverpod pod) async {
  if (pod.runMode != ServerpodRunMode.development) {
    throw StateError('Demo account creation is only allowed in development.');
  }
  await _createAccount(pod, 'demo@garden.local', 'garden-demo');
}

Future<void> seedJudgeDemoAccount(Serverpod pod) async {
  final password = pod.getPassword('judgeDemoPassword');
  if (password == null) return;
  if (password.length < 32) {
    throw StateError(
      'The judge demo password must contain at least 32 characters.',
    );
  }
  await _createAccount(pod, 'judge-demo@garden.invalid', password);
}

Future<void> _createAccount(
  Serverpod pod,
  String email,
  String password,
) async {
  final session = await pod.createSession();
  try {
    final auth = AuthServices.instance;
    await session.db.transaction((transaction) async {
      // Serialize bootstrap across backend instances without polling.
      await session.db.unsafeQuery(
        'SELECT pg_advisory_xact_lock(784165902)',
        transaction: transaction,
      );
      if (await auth.emailIdp.admin.findAccount(
            session,
            email: email,
            transaction: transaction,
          ) !=
          null)
        return;
      final user = await auth.authUsers.create(
        session,
        transaction: transaction,
      );
      await auth.emailIdp.admin.createEmailAuthentication(
        session,
        authUserId: user.id,
        email: email,
        password: password,
        transaction: transaction,
      );
      await auth.userProfiles.createUserProfile(
        session,
        user.id,
        UserProfileData(email: email),
        transaction: transaction,
      );
      session.log('Garden demo account created.');
    });
  } finally {
    await session.close();
  }
}
