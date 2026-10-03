import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

Future<String> partChecksum(Uint8List bytes) async {
  final input = TransferableTypedData.fromList([bytes]);
  return Isolate.run(
    () => md5.convert(input.materialize().asUint8List()).toString(),
  );
}
