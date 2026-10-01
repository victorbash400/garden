import 'dart:convert';
import 'package:serverpod/serverpod.dart';

class AppAssociationRoute extends Route {
  AppAssociationRoute() : super(methods: {Method.get});
  @override
  Future<Result> handleCall(Session session, Request request) async =>
      Response.ok(
        body: Body.fromString(
          jsonEncode({
            'webcredentials': {
              'apps': ['387H4ZZF2K.com.victorbash.garden'],
            },
          }),
          mimeType: MimeType.json,
        ),
      );
}
