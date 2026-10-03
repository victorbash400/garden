import 'package:flutter/foundation.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';

enum FinderUpdateState { idle, connecting, running, disconnected }

abstract class FinderUpdates extends ChangeNotifier {
  FinderUpdateState get state;
  String? get error;
  Future<void> sync(AccountInfo account, List<GardenInfo> drives);
  Future<void> close();
}
