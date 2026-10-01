import 'dart:convert';
import 'dart:io';
import 'package:googleapis/cloudtasks/v2.dart' as tasks;
import 'package:googleapis_auth/auth_io.dart';
import 'package:serverpod/serverpod.dart';
import '../generated/future_calls.dart';
import 'upload_cleanup_route.dart';

class UploadCleanupTasks {
  static late tasks.CloudTasksApi _api;
  static late String _queue;
  static late String _url;
  static late String _secret;

  static bool _local(Serverpod pod) =>
      pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test;

  static Future<void> configure(Serverpod pod) async {
    if (_local(pod)) return;
    _queue = Platform.environment['GARDEN_UPLOAD_CLEANUP_QUEUE'] ?? '';
    _url = Platform.environment['GARDEN_UPLOAD_CLEANUP_URL'] ?? '';
    _secret = pod.getPassword('uploadCleanupToken') ?? '';
    final credentials = pod.getPassword('gcpServiceAccount');
    if (_queue.isEmpty ||
        !Uri.parse(_url).isScheme('https') ||
        _secret.length < 32 ||
        credentials == null) {
      throw StateError('Upload cleanup Cloud Tasks configuration is required.');
    }
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(credentials),
      [tasks.CloudTasksApi.cloudPlatformScope],
    );
    _api = tasks.CloudTasksApi(client);
    pod.webServer.addRoute(
      UploadCleanupRoute(_secret),
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
    await _api.projects.locations.queues.tasks.create(
      tasks.CreateTaskRequest(
        task: tasks.Task(
          scheduleTime: DateTime.now()
              .toUtc()
              .add(const Duration(hours: 24))
              .toIso8601String(),
          httpRequest: tasks.HttpRequest(
            url: _url,
            httpMethod: 'POST',
            headers: {
              'Authorization': 'Bearer $_secret',
              'Content-Type': 'text/plain',
            },
            body: base64Encode(utf8.encode('$versionId')),
          ),
        ),
      ),
      _queue,
    );
  }
}
