import 'dart:io';
import 'package:aws_client/scheduler.dart' as aws;
import 'package:serverpod/serverpod.dart';
import '../generated/future_calls.dart';
import 'upload_cleanup_route.dart';

class UploadCleanupTasks {
  static aws.Scheduler? _scheduler;
  static late String _lambdaArn;
  static late String _roleArn;

  static bool _local(Serverpod pod) =>
      pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test;

  static Future<void> configure(Serverpod pod) async {
    if (_local(pod)) return;
    final region = Platform.environment['GARDEN_S3_REGION'];
    _lambdaArn = Platform.environment['GARDEN_UPLOAD_CLEANUP_LAMBDA_ARN'] ?? '';
    _roleArn = Platform.environment['GARDEN_UPLOAD_CLEANUP_ROLE_ARN'] ?? '';
    final token = pod.getPassword('uploadCleanupToken');
    final accessKey = pod.getPassword('AWSAccessKeyId');
    final secretKey = pod.getPassword('AWSSecretKey');
    if (region == null ||
        region.isEmpty ||
        _lambdaArn.isEmpty ||
        _roleArn.isEmpty ||
        token == null ||
        token.length < 32 ||
        accessKey == null ||
        secretKey == null) {
      throw StateError('AWS upload cleanup configuration is required.');
    }
    _scheduler = aws.Scheduler(
      region: region,
      credentials: aws.AwsClientCredentials(
        accessKey: accessKey,
        secretKey: secretKey,
      ),
    );
    pod.webServer.addRoute(
      UploadCleanupRoute(token),
      '/internal/upload-cleanup',
    );
  }

  static Future<void> schedule(Session session, int versionId) async {
    if (_local(session.serverpod)) {
      await session.serverpod.futureCalls
          .callWithDelay(const Duration(hours: 24))
          .uploadCleanup
          .expire(versionId);
      return;
    }
    final due = DateTime.now().toUtc().add(
      const Duration(hours: 24, minutes: 5),
    );
    final timestamp = due.toIso8601String().substring(0, 19);
    await _scheduler!.createSchedule(
      name: 'upload-$versionId',
      groupName: 'garden-upload-cleanup',
      scheduleExpression: 'at($timestamp)',
      scheduleExpressionTimezone: 'UTC',
      actionAfterCompletion: aws.ActionAfterCompletion.delete,
      flexibleTimeWindow: aws.FlexibleTimeWindow(
        mode: aws.FlexibleTimeWindowMode.off,
      ),
      target: aws.Target(
        arn: _lambdaArn,
        roleArn: _roleArn,
        input: '$versionId',
        retryPolicy: aws.RetryPolicy(
          maximumEventAgeInSeconds: 3600,
          maximumRetryAttempts: 3,
        ),
      ),
    );
  }
}
