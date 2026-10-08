import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'verify_demo.dart' show MemoryAuthStorage;

Future<int> transfer(String url, {Uint8List? bytes}) async {
  final http = HttpClient();
  try {
    final request = await http.openUrl(
      bytes == null ? 'GET' : 'PUT',
      Uri.parse(url),
    );
    if (bytes != null) {
      request.contentLength = bytes.length;
      request.add(bytes);
    }
    final response = await request.close();
    await response.drain<void>();
    return response.statusCode;
  } finally {
    http.close(force: true);
  }
}

Future<void> main(List<String> args) async {
  if (args.length != 1)
    throw ArgumentError('Provide the private disposable signup state file.');
  final file = File(args.single);
  final state = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  if (state['disposable'] != true ||
      state['verified'] != true ||
      state['purpose'] != 'garden-account-deletion-e2e') {
    throw StateError(
      'This probe only deletes a verified account created for this test.',
    );
  }
  final client = Client(state['api'] as String);
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  try {
    final login = await client.emailIdp.login(
      email: state['email'] as String,
      password: state['password'] as String,
    );
    await auth.updateSignedInUser(login);
    if ((await client.garden.account()).email != state['email'])
      throw StateError('Unexpected account.');
    final drive = await client.garden.create('Disposable account cleanup');
    final node = await client.files.create(
      drive.id,
      0,
      'fixture.bin',
      NodeKind.file,
    );
    final bytes = Uint8List.fromList(
      List.generate(600000, (index) => index % 251),
    );
    final legacy = await client.content.begin(node.id!, 0, bytes.length);
    for (
      var start = 0, index = 0;
      start < bytes.length;
      start += 262144, index++
    ) {
      await client.content.writeChunk(
        legacy.id!,
        index,
        ByteData.sublistView(
          bytes,
          start,
          (start + 262144).clamp(0, bytes.length),
        ),
      );
    }
    var saved = await client.content.finish(legacy.id!);
    final upload = await client.content.beginMultipart(
      node.id!,
      saved.version,
      bytes.length,
    );
    final url = (await client.content.uploadParts(upload.id!, 1, 1)).single;
    if (await transfer(url, bytes: bytes) != 200)
      throw StateError('Fixture multipart upload failed.');
    saved = await client.content.finish(upload.id!);
    final download = await client.content.download(node.id!, saved.version);
    if (await transfer(
          download.url ?? (throw StateError('Fixture download URL missing.')),
        ) !=
        200)
      throw StateError('Fixture object download failed.');
    final pending = await client.content.beginMultipart(
      node.id!,
      saved.version,
      bytes.length,
    );
    final pendingUrl = (await client.content.uploadParts(
      pending.id!,
      1,
      1,
    )).single;
    await client.account.deleteAccount(state['email'] as String);
    if (await transfer(
          download.url ?? (throw StateError('Fixture download URL missing.')),
        ) !=
        404)
      throw StateError('The cloud object survived account deletion.');
    if (await transfer(pendingUrl, bytes: bytes) != 404)
      throw StateError(
        'The pending multipart upload survived account deletion.',
      );
    try {
      await client.garden.account();
      throw StateError('The old access token remains authorized.');
    } on ServerpodClientUnauthorized {}
    try {
      await client.emailIdp.login(
        email: state['email'] as String,
        password: state['password'] as String,
      );
      throw StateError('The deleted identity can still sign in.');
    } on EmailAccountLoginException {}
    state.remove('requestId');
    state.remove('code');
    state['verified'] = false;
    state['deleted'] = true;
    await file.writeAsString(jsonEncode(state));
    print(
      'Hosted deletion passed: cloud object removed, multipart upload aborted, old session rejected and old login rejected.',
    );
  } finally {
    client.close();
  }
}
