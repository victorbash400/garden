import 'package:garden_client/garden_client.dart';

String errorMessage(Object error) => switch (error) {
  GardenException() => error.message,
  _ => error.toString(),
};
