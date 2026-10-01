import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_gcp/serverpod_cloud_storage_gcp.dart';

Future<void> configureFileStorage(Serverpod pod) async {
  if (pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test) {
    pod.addCloudStorage(DatabaseCloudStorage('private'));
    return;
  }
  final bucket = Platform.environment['GARDEN_STORAGE_BUCKET'];
  if (bucket == null || bucket.isEmpty) {
    throw StateError('GARDEN_STORAGE_BUCKET is required.');
  }
  pod.addCloudStorage(
    await NativeGoogleCloudStorage.create(
      serverpod: pod,
      storageId: 'private',
      public: false,
      bucket: bucket,
    ),
  );
}
