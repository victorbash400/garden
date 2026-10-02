import 'dart:io';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3/serverpod_cloud_storage_s3.dart';

Future<void> configureFileStorage(Serverpod pod) async {
  if (pod.runMode == ServerpodRunMode.development ||
      pod.runMode == ServerpodRunMode.test) {
    pod.addCloudStorage(DatabaseCloudStorage('private'));
    return;
  }
  final bucket = Platform.environment['GARDEN_S3_BUCKET'];
  final region = Platform.environment['GARDEN_S3_REGION'];
  if (bucket == null || bucket.isEmpty || region == null || region.isEmpty) {
    throw StateError('GARDEN_S3_BUCKET and GARDEN_S3_REGION are required.');
  }
  pod.addCloudStorage(
    S3CloudStorage(
      serverpod: pod,
      storageId: 'private',
      public: false,
      bucket: bucket,
      region: region,
    ),
  );
}
