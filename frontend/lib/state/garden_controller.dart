import 'package:flutter/foundation.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/preferences_store.dart';

enum GardenPage {
  welcome,
  signIn,
  register,
  verify,
  gardens,
  create,
  join,
  connected,
  settings,
}

class GardenController extends ChangeNotifier {
  GardenController(this.gateway, this.preferences);
  final GardenGateway gateway;
  final PreferencesStore preferences;
  GardenPage page = GardenPage.welcome;
  AccountInfo? account;
  List<GardenInfo> gardens = [];
  GardenInfo? selected;
  bool busy = false;
  String? error;
  int cacheLimit = 20;
  String? registrationId;
  String registrationEmail = '';
  String registrationPassword = '';

  Future<void> initialize() => _request(() async {
    cacheLimit = await preferences.readCacheLimit();
    account = await gateway.restoreAccount();
    if (account != null) {
      gardens = await gateway.listGardens();
      page = GardenPage.gardens;
    }
  });

  void navigate(GardenPage destination) {
    if (busy) return;
    page = destination;
    error = null;
    notifyListeners();
  }

  void back() {
    if (busy) return;
    navigate(switch (page) {
      GardenPage.signIn || GardenPage.register => GardenPage.welcome,
      GardenPage.verify => GardenPage.register,
      GardenPage.create ||
      GardenPage.join ||
      GardenPage.connected => GardenPage.gardens,
      GardenPage.settings =>
        account == null ? GardenPage.welcome : GardenPage.gardens,
      _ => GardenPage.welcome,
    });
  }

  Future<void> signIn(String email, String password) => _request(() async {
    account = await gateway.signIn(email.trim(), password);
    page = GardenPage.gardens;
    gardens = await gateway.listGardens();
  });

  Future<void> register(String email, String password) => _request(() async {
    registrationId = await gateway.beginRegistration(email.trim());
    registrationEmail = email.trim();
    registrationPassword = password;
    page = GardenPage.verify;
  });

  Future<void> verify(String code) => _request(() async {
    final id = registrationId;
    if (id == null) throw StateError('Registration has not started.');
    account = await gateway.finishRegistration(
      id,
      code.trim(),
      registrationPassword,
    );
    registrationPassword = '';
    registrationId = null;
    page = GardenPage.gardens;
    gardens = await gateway.listGardens();
  });

  Future<void> refresh() => _request(() async {
    gardens = await gateway.listGardens();
  });
  Future<void> create(String name) => _request(() async {
    selected = await gateway.createGarden(name.trim());
    page = GardenPage.connected;
    gardens = await gateway.listGardens();
  });
  Future<void> join(String code) => _request(() async {
    selected = await gateway.joinGarden(code.trim());
    page = GardenPage.connected;
    gardens = await gateway.listGardens();
  });
  Future<void> connect(GardenInfo garden) => _request(() async {
    selected = await gateway.connect(garden.id);
    page = GardenPage.connected;
  });
  Future<void> signOut() => _request(() async {
    await gateway.signOut();
    account = null;
    gardens = [];
    selected = null;
    registrationPassword = '';
    registrationId = null;
    page = GardenPage.welcome;
  });
  Future<void> setCacheLimit(int gib) => _request(() async {
    if (gib < 1 || gib > 100) {
      throw ArgumentError('Cache limit must be between 1 and 100 GiB.');
    }
    await preferences.saveCacheLimit(gib);
    cacheLimit = gib;
  });

  Future<void> _request(Future<void> Function() action) async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = failure.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
