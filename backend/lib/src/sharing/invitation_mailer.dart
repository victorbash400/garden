import 'dart:io';
import 'package:aws_client/ses_v2.dart' as aws;
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class InvitationMailer {
  static Future<DriveInvitation> send(
    Session session,
    DriveInvitation invitation,
    String driveName,
  ) async {
    invitation.deliveryMessageId = null;
    final sender = Platform.environment['GARDEN_EMAIL_FROM'];
    final region =
        Platform.environment['GARDEN_EMAIL_REGION'] ??
        Platform.environment['GARDEN_S3_REGION'];
    final access = session.serverpod.getPassword('AWSAccessKeyId');
    final secret = session.serverpod.getPassword('AWSSecretKey');
    if (sender == null || region == null || access == null || secret == null) {
      invitation.deliveryStatus = 'notConfigured';
      invitation.deliveryError = 'Invitation email sending is not configured.';
      return _save(session, invitation);
    }
    final client = aws.SesV2(
      region: region,
      credentials: aws.AwsClientCredentials(
        accessKey: access,
        secretKey: secret,
      ),
    );
    try {
      final response = await client.sendEmail(
        fromEmailAddress: sender,
        destination: aws.Destination(toAddresses: [invitation.recipientEmail]),
        content: aws.EmailContent(
          simple: aws.Message(
            subject: aws.Content(data: 'Invitation to $driveName'),
            body: aws.Body(
              text: aws.Content(
                data:
                    'You have been invited to $driveName in Garden with ${invitation.role} permission.\n\nSign in to Garden using ${invitation.recipientEmail} and open Notifications to accept or decline.\n\nThis invitation expires on ${invitation.expiresAt.toIso8601String()}.',
              ),
            ),
          ),
        ),
      );
      if (response.messageId == null) {
        throw StateError('SES did not acknowledge the email.');
      }
      invitation.deliveryStatus = 'accepted';
      invitation.deliveryMessageId = response.messageId;
      invitation.deliveryError = null;
    } catch (error, stack) {
      invitation.deliveryStatus = 'failed';
      invitation.deliveryError =
          'The invitation email could not be sent. Retry sending.';
      session.log(
        'Invitation email delivery failed.',
        level: LogLevel.error,
        exception: error,
        stackTrace: stack,
      );
    } finally {
      client.close();
    }
    return _save(session, invitation);
  }

  static Future<DriveInvitation> _save(
    Session session,
    DriveInvitation invitation,
  ) => DriveInvitation.db.updateRow(
    session,
    invitation,
    columns: (row) => [
      row.deliveryStatus,
      row.deliveryMessageId,
      row.deliveryError,
    ],
  );
}
