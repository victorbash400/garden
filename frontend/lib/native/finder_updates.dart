import 'package:flutter/foundation.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import 'finder_status.dart';

enum FinderUpdateState { idle, connecting, running, disconnected }

abstract class FinderUpdates extends ChangeNotifier {
  FinderUpdateState get state;
  String? get error;
  FinderStatus? get status;
  Future<void> sync(AccountInfo account, List<GardenInfo> drives);
  Future<void> close();
}
