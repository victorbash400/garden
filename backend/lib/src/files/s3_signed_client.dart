import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

class S3SignedClient extends http.BaseClient {
  S3SignedClient(String access, String secret, String region)
    : signer = AWSSigV4Signer(
        credentialsProvider: AWSCredentialsProvider(
          AWSCredentials(access, secret),
        ),
      ),
      scope = AWSCredentialScope(region: region, service: AWSService.s3);

  final AWSSigV4Signer signer;
  final AWSCredentialScope scope;
  final http.Client transport = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is! http.Request) {
      throw StateError('S3 metadata requests must have a bounded body.');
    }
    final headers = Map<String, String>.from(request.headers);
    for (final name in [
      'authorization',
      'x-amz-date',
      'x-amz-content-sha256',
    ]) {
      headers.removeWhere((key, _) => key.toLowerCase() == name);
    }
    final signed = await signer.sign(
      AWSHttpRequest(
        method: AWSHttpMethod.fromString(request.method),
        uri: request.url,
        headers: headers,
        body: request.bodyBytes,
      ),
      credentialScope: scope,
      serviceConfiguration: S3ServiceConfiguration(),
    );
    request.headers
      ..clear()
      ..addAll(signed.headers);
    return transport.send(request);
  }

  @override
  void close() => transport.close();
}
