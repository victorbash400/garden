import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aws_client/s3.dart' as aws;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3/serverpod_cloud_storage_s3.dart';
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';

import '../generated/protocol.dart';
import 's3_signed_client.dart';

class MultipartObjectStore {
  MultipartObjectStore(Session session) {
    bucket = Platform.environment['GARDEN_S3_BUCKET'] ?? '';
    final region = Platform.environment['GARDEN_S3_REGION'] ?? '';
    final access = session.serverpod.getPassword('AWSAccessKeyId');
    final secret = session.serverpod.getPassword('AWSSecretKey');
    if (bucket.isEmpty || region.isEmpty || access == null || secret == null) {
      throw GardenException(
        message: 'Direct file transfers are not configured.',
      );
    }
    client = aws.S3(
      region: region,
      client: transport = S3SignedClient(access, secret, region),
      credentials: aws.AwsClientCredentials(
        accessKey: access,
        secretKey: secret,
      ),
    );
    signer = S3Client(
      accessKey: access,
      secretKey: secret,
      bucket: bucket,
      region: region,
      endpoints: const AwsEndpointConfig(),
    );
  }

  late final String bucket;
  late final aws.S3 client;
  late final S3SignedClient transport;
  late final S3Client signer;

  static int partSizeFor(int size) {
    const unit = 1024 * 1024;
    return max(8 * unit, ((size + 9999) ~/ 10000 + unit - 1) ~/ unit * unit);
  }

  void close() {
    client.close();
    transport.close();
    signer.close();
  }

  Future<String> begin(String path) async {
    final result = await client.createMultipartUpload(
      bucket: bucket,
      key: path,
    );
    final id = result.uploadId;
    if (id == null) throw StateError('S3 did not return an upload identifier.');
    return id;
  }

  List<String> partUrls(FileVersion version, int first, int count) {
    if (first < 1 ||
        count < 1 ||
        count > 32 ||
        first + count - 1 > version.chunkCount) {
      throw GardenException(message: 'Invalid upload part range.');
    }
    return List.generate(
      count,
      (index) => signer
          .buildPresignedUri(
            key: version.objectPath!,
            method: 'PUT',
            expiration: const Duration(hours: 1),
            queryParams: {
              'uploadId': version.uploadId!,
              'partNumber': '${first + index}',
            },
          )
          .toString(),
    );
  }

  static void validateParts(FileVersion version, List<aws.Part> parts) {
    if (parts.length != version.chunkCount) {
      throw GardenException(message: 'The upload is incomplete.');
    }
    for (var index = 0; index < parts.length; index++) {
      final part = parts[index];
      final expected = min(
        version.partSize!,
        version.size - index * version.partSize!,
      );
      if (part.partNumber != index + 1 ||
          part.size != expected ||
          part.eTag == null) {
        throw GardenException(message: 'Invalid uploaded file part.');
      }
    }
  }

  Future<List<aws.Part>> parts(FileVersion version) async {
    final parts = <aws.Part>[];
    String? marker;
    do {
      final page = await client.listParts(
        bucket: bucket,
        key: version.objectPath!,
        uploadId: version.uploadId!,
        partNumberMarker: marker,
      );
      parts.addAll(page.parts ?? []);
      if (page.isTruncated != true) break;
      final next = page.nextPartNumberMarker;
      if (next == null || next == marker) {
        throw StateError('Invalid S3 part pagination.');
      }
      marker = next;
    } while (true);
    return parts;
  }

  Future<void> copyParts(
    FileVersion upload,
    FileVersion base,
    int first,
    List<String> ranges,
  ) async {
    final source = '$bucket/${base.objectPath!}'
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');
    for (var index = 0; index < ranges.length; index++) {
      final result = await client.uploadPartCopy(
        bucket: bucket,
        key: upload.objectPath!,
        uploadId: upload.uploadId!,
        partNumber: first + index,
        copySource: source,
        copySourceRange: ranges[index],
      );
      if (result.copyPartResult?.eTag == null) {
        throw StateError('S3 did not confirm the copied part.');
      }
    }
  }

  Future<void> complete(FileVersion version) async {
    final parts = await this.parts(version);
    validateParts(version, parts);
    await client.completeMultipartUpload(
      bucket: bucket,
      key: version.objectPath!,
      uploadId: version.uploadId!,
      ifNoneMatch: '*',
      multipartUpload: aws.CompletedMultipartUpload(
        parts: parts
            .map(
              (part) => aws.CompletedPart(
                partNumber: part.partNumber,
                eTag: part.eTag,
              ),
            )
            .toList(),
      ),
    );
  }

  ContentDownload download(FileVersion version) => ContentDownload(
    url: signer
        .buildPresignedUri(
          key: version.objectPath!,
          method: 'GET',
          expiration: const Duration(minutes: 2),
        )
        .toString(),
    size: version.size,
    expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 2)),
  );

  Future<Uint8List> read(String path, int offset, int length) async {
    final response = await client.getObject(
      bucket: bucket,
      key: path,
      range: 'bytes=$offset-${offset + length - 1}',
    );
    final bytes = response.body;
    if (bytes == null || bytes.length != length) {
      throw StateError('Incomplete S3 range.');
    }
    return bytes;
  }

  Future<void> abort(FileVersion version) async {
    await client.abortMultipartUpload(
      bucket: bucket,
      key: version.objectPath!,
      uploadId: version.uploadId!,
    );
  }
}
