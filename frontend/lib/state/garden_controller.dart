import 'package:flutter/foundation.dart';

import '../utils/error_message.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/preferences_store.dart';
import 'files_controller.dart';

enum SettingsSection { account, storage }

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
  files,
}

class GardenController extends ChangeNotifier {
  GardenController(
    this.gateway,
    this.preferences, {
    this.files,
    this.localServer = false,
  });
  final bool localServer;
  final FilesController? files;
  final GardenGateway gateway;
  final PreferencesStore preferences;
  GardenPage page = GardenPage.signIn;
  SettingsSection settingsSection = SettingsSection.account;
  GardenPage _settingsReturn = GardenPage.gardens;
  AccountInfo? account;
  List<GardenInfo> gardens = [];
  GardenInfo? selected;
  bool _busy = false;
  bool get busy => _busy || (files?.busy ?? false);
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
    if (destination == GardenPage.settings && page != GardenPage.settings) {
      _settingsReturn = page;
    }
    page = destination;
    error = null;
    notifyListeners();
  }

  void selectSettings(SettingsSection section) {
    if (busy) return;
    settingsSection = section;
    error = null;
    notifyListeners();
  }

  void back() {
    if (busy) return;
    navigate(switch (page) {
      GardenPage.signIn || GardenPage.register => GardenPage.signIn,
      GardenPage.verify => GardenPage.register,
      GardenPage.create ||
      GardenPage.join ||
      GardenPage.files ||
      GardenPage.connected => GardenPage.gardens,
      GardenPage.settings =>
        account == null ? GardenPage.signIn : _settingsReturn,
      _ => GardenPage.signIn,
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

  Future<void> resendVerification() => _request(() async {
    if (registrationEmail.isEmpty) {
      throw StateError('Registration has not started.');
    }
    registrationId = await gateway.beginRegistration(registrationEmail);
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
  Future<void> openDrive(GardenInfo drive) async {
    if (busy) return;
    if (files?.drive?.id == drive.id) {
      await files!.goTo(0);
      navigate(GardenPage.files);
      return;
    }
    await connect(drive);
    if (error == null && files != null) await openFiles();
  }

  Future<void> openFiles() => _request(() async {
    final browser = files;
    final drive = selected;
    if (browser == null || drive == null) {
      throw StateError('No drive is connected.');
    }
    await browser.open(drive);
    page = GardenPage.files;
  });
  Future<void> signOut() => _request(() async {
    await files?.close();
    await gateway.signOut();
    account = null;
    gardens = [];
    selected = null;
    registrationPassword = '';
    registrationId = null;
    page = GardenPage.signIn;
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
    _busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } catch (failure) {
      error = errorMessage(failure);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
