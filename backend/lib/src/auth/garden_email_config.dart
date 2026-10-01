import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';

EmailIdpConfig gardenEmailConfig(Serverpod pod) {
  final defaults = ServerpodCloudEmailIdpConfig(appDisplayName: 'Garden');
  if (pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test) {
    return defaults;
  }
  final client = ServerpodCloudEmailClient();
  return EmailIdpConfigFromPasswords(
    sendPasswordResetVerificationCode:
        defaults.sendPasswordResetVerificationCode,
    sendRegistrationVerificationCode:
        (
          session, {
          required email,
          required accountRequestId,
          required verificationCode,
          required transaction,
        }) async {
          try {
            await client.sendEmail(
              token:
                  pod.getPassword('scloudAuthEmailKey') ??
                  (throw StateError('Cloud email credentials are missing.')),
              emailType: ServerpodCloudEmailType.signup,
              email: email,
              projectName: 'Garden',
              authCode: verificationCode,
            );
          } catch (error, stackTrace) {
            session.log(
              'Registration email delivery failed.',
              level: LogLevel.error,
              exception: error,
              stackTrace: stackTrace,
            );
            throw GardenException(
              message:
                  'Could not send the verification email. Please try again.',
            );
          }
        },
  );
}
