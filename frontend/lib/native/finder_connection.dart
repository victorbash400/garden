import '../model/garden_info.dart';

sealed class FinderConnectionState {
  const FinderConnectionState();
}

class FinderUnavailable extends FinderConnectionState {
  const FinderUnavailable(this.reason);
  final String reason;
}

class FinderMounted extends FinderConnectionState {
  const FinderMounted(this.mountPath);
  final String mountPath;
}

abstract interface class FinderConnection {
  Stream<FinderConnectionState> get changes;
  Future<FinderConnectionState> connect(GardenInfo garden);
  Future<void> disconnect();
  Future<void> dispose();
}

class UnavailableFinderConnection implements FinderConnection {
  @override
  Stream<FinderConnectionState> get changes => const Stream.empty();
  @override
  Future<FinderConnectionState> connect(GardenInfo garden) async =>
      const FinderUnavailable('Finder mounting is not available yet.');
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> dispose() async {}
}
