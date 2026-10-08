import 'dart:async';

import 'package:garden_client/garden_client.dart';

class AuthenticatedClient extends Client {
  AuthenticatedClient(super.host, {required this.checkSession});
  final Future<void> Function() checkSession;

  Future<T> _checked<T>(Future<T> request) async {
    try {
      return await request;
    } on ServerpodClientUnauthorized {
      await checkSession();
      rethrow;
    }
  }

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) => _checked(
    super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    ),
  );

  Stream<G> _watch<G>(Stream<G> source) async* {
    try {
      yield* source;
    } on ServerpodClientUnauthorized {
      await checkSession();
      rethrow;
    }
  }

  @override
  dynamic callStreamingServerEndpoint<T, G>(
    String endpoint,
    String method,
    Map<String, dynamic> args,
    Map<String, Stream> streams, {
    bool authenticated = true,
  }) {
    final result = super.callStreamingServerEndpoint<T, G>(
      endpoint,
      method,
      args,
      streams,
      authenticated: authenticated,
    );
    if (result is Stream<G>) return _watch(result);
    if (result is Future<G>) return _checked(result);
    return result;
  }
}
