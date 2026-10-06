import 'package:garden_client/garden_client.dart';

abstract interface class InboxService {
  Future<InboxSnapshot> snapshot();
  Stream<InboxEvent> watch(int cursor);
  Future<void> seen(int conversation);
}

class ServerpodInboxService implements InboxService {
  ServerpodInboxService(this.client);
  final Client client;
  @override
  Future<InboxSnapshot> snapshot() => client.inbox.snapshot();
  @override
  Future<void> seen(int conversation) => client.inbox.seen(conversation);
  @override
  Stream<InboxEvent> watch(int cursor) => client.inbox.watch(cursor);
}
