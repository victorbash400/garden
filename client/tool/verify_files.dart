import 'dart:async';
import 'dart:typed_data';
import 'package:garden_client/garden_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'verify_demo.dart' show MemoryAuthStorage;

Future<Client> signedIn() async {
  final client = Client('http://localhost:8080/');
  final auth = ClientAuthSessionManager(
    storage: MemoryAuthStorage(),
    caller: client.modules.serverpod_auth_core,
  );
  client.authKeyProvider = auth;
  await auth.updateSignedInUser(
    await client.emailIdp.login(
      email: 'demo@garden.local',
      password: 'garden-demo',
    ),
  );
  return client;
}

void check(bool result, String message) {
  if (!result) throw StateError(message);
}

Future<void> main() async {
  final a = await signedIn();
  final b = await signedIn();
  StreamIterator<DriveEvent>? stream;
  final created = <int>[];
  int? folderId;
  try {
    final drives = await a.garden.list();
    if (drives.isEmpty)
      throw StateError('Create a demo drive before running this verification.');
    final drive = drives.first;
    final snapshot = await b.files.list(drive.id, 0);
    stream = StreamIterator(b.files.watch(drive.id, snapshot.revision));
    check(
      await stream.moveNext().timeout(const Duration(seconds: 5)),
      'Stream did not become ready.',
    );
    check(stream.current.operation == 'ready', 'Unexpected initial event.');
    final folder = await a.files.create(
      drive.id,
      0,
      'Verification ${DateTime.now().microsecondsSinceEpoch}',
      NodeKind.folder,
    );
    folderId = folder.id;
    check(
      await stream.moveNext().timeout(const Duration(seconds: 5)),
      'No live folder event.',
    );
    check(stream.current.node!.id == folder.id, 'Wrong live folder event.');
    final file = await a.files.create(
      drive.id,
      folder.id!,
      'sample.bin',
      NodeKind.file,
    );
    created.add(file.id!);
    final bytes = Uint8List.fromList(
      List.generate(600000, (index) => index % 251),
    );
    final upload = await a.content.begin(file.id!, 0, bytes.length);
    for (
      var offset = 0, index = 0;
      offset < bytes.length;
      offset += 262144, index++
    ) {
      await a.content.writeChunk(
        upload.id!,
        index,
        ByteData.sublistView(
          bytes,
          offset,
          (offset + 262144).clamp(0, bytes.length),
        ),
      );
    }
    final saved = await a.content.finish(upload.id!);
    final read = await b.content.read(file.id!, saved.version, 262130, 40);
    final actual = read.buffer.asUint8List(
      read.offsetInBytes,
      read.lengthInBytes,
    );
    check(actual.length == 40, 'Wrong range length.');
    for (var i = 0; i < actual.length; i++) {
      check(actual[i] == bytes[262130 + i], 'Range content mismatch.');
    }
    await b.collaboration.comment(file.id!, 'Verified from another session');
    check(
      (await a.collaboration.comments(file.id!)).single.text ==
          'Verified from another session',
      'Comment did not persist.',
    );
    final left = await a.content.begin(file.id!, saved.version, 0);
    final right = await b.content.begin(file.id!, saved.version, 0);
    final concurrent = await Future.wait([
      a.content.finish(left.id!),
      b.content.finish(right.id!),
    ]);
    final conflict = concurrent.firstWhere((node) => node.id != file.id);
    created.add(conflict.id!);
    check(
      concurrent.map((node) => node.id).toSet().length == 2,
      'Concurrent saves overwrote one another.',
    );
    final versions = await a.content.versions(file.id!);
    check(versions.length == 2, 'Version history was not retained.');
    await a.files.move(conflict.id!, folder.id!, 'conflict-preserved.bin');
    final contents = await b.files.list(drive.id, folder.id!);
    check(contents.nodes.length == 2, 'Directory state mismatch.');
    await stream.cancel();
    stream = null;
    final replay = StreamIterator(b.files.watch(drive.id, snapshot.revision));
    var previous = snapshot.revision;
    try {
      while (await replay.moveNext().timeout(const Duration(seconds: 5))) {
        final event = replay.current;
        if (event.operation == 'ready') break;
        check(
          event.revision == previous + 1,
          'Replay revisions were not ordered.',
        );
        previous = event.revision;
      }
    } finally {
      await replay.cancel();
    }
    print(
      'Verified two authenticated client sessions: live push, chunk upload, cross-boundary read, comments, concurrent conflict preservation, rename, directory state, and ordered replay.',
    );
  } finally {
    await stream?.cancel();
    for (final id in created.reversed) {
      await a.files.delete(id);
    }
    if (folderId != null) await a.files.delete(folderId);
    await (a.authKeyProvider! as ClientAuthSessionManager).signOutDevice();
    await (b.authKeyProvider! as ClientAuthSessionManager).signOutDevice();
    a.close();
    b.close();
  }
}
