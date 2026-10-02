import 'package:flutter/foundation.dart';

import '../utils/error_message.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/preferences_store.dart';
import '../native/mac_finder_mounts.dart';
import '../native/mac_finder_updates.dart';
import 'files_controller.dart';
import 'account_security_controller.dart';

enum SettingsSection { account, storage }

enum GardenPage {
  welcome,
  signIn,
  register,
  verify,
  gardens,
  create,
  join,
  settings,
  files,
}

class GardenController extends ChangeNotifier {
  GardenController(
    this.gateway,
    this.preferences, {
    this.files,
    this.security,
    this.finder,
    this.finderUpdates,
    this.localServer = false,
  });
  final AccountSecurityController? security;
  final MacFinderMounts? finder;
  final MacFinderUpdates? finderUpdates;
  int get mountedDriveCount => finder?.mountedDriveIDs.length ?? 0;
  final bool localServer;
  final FilesController? files;
  final GardenGateway gateway;
  final PreferencesStore preferences;
  GardenPage page = GardenPage.signIn;
  SettingsSection settingsSection = SettingsSection.account;
  GardenPage _settingsReturn = GardenPage.gardens;
  AccountInfo? account;
  String? savedEmail;
  bool rememberLogin = false;
  List<GardenInfo> gardens = [];
  GardenInfo? selected;
  bool _busy = false;
  Future<void> _finderWork = Future.value();
  bool get busy => _busy || (files?.busy ?? false);
  String? error;
  int cacheLimit = 20;
  String? registrationId;
  String registrationEmail = '';
  String registrationPassword = '';

  Future<void> initialize() => _request(() async {
    cacheLimit = await preferences.readCacheLimit();
    savedEmail = await gateway.savedLogin();
    await security?.checkConfiguration();
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
      GardenPage.files => GardenPage.gardens,
      GardenPage.settings =>
        account == null ? GardenPage.signIn : _settingsReturn,
      _ => GardenPage.signIn,
    });
  }

  void setRememberLogin(bool value) {
    rememberLogin = value;
    notifyListeners();
  }

  Future<void> continueSavedLogin() => _request(() async {
    account = await gateway.restoreAccount();
    if (account == null) {
      await gateway.forgetSavedLogin();
      savedEmail = null;
      throw StateError('Saved login expired. Sign in again.');
    }
    gardens = await gateway.listGardens();
    page = GardenPage.gardens;
    _queueFinderSync();
  });
  Future<void> forgetSavedLogin() => _request(() async {
    await gateway.forgetSavedLogin();
    savedEmail = null;
  });
  Future<void> signIn(String email, String password) => _request(() async {
    account = await gateway.signIn(
      email.trim(),
      password,
      remember: rememberLogin,
    );
    page = GardenPage.gardens;
    gardens = await gateway.listGardens();
    _queueFinderSync();
  });

  Future<void> signInWithPasskey() => _request(() async {
    final auth = security;
    if (auth == null) throw StateError('Passkeys are unavailable.');
    account = await auth.gateway.signInWithPasskey(remember: rememberLogin);
    gardens = await gateway.listGardens();
    page = GardenPage.gardens;
    _queueFinderSync();
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
    _queueFinderSync();
  });

  Future<void> resendVerification() => _request(() async {
    if (registrationEmail.isEmpty) {
      throw StateError('Registration has not started.');
    }
    registrationId = await gateway.beginRegistration(registrationEmail);
  });

  Future<void> refresh() => _request(() async {
    gardens = await gateway.listGardens();
    _queueFinderSync();
  });
  Future<void> _showDrive(GardenInfo drive) async {
    final browser = files;
    if (browser == null) throw StateError('File browser is unavailable.');
    selected = drive;
    await browser.open(drive);
    page = GardenPage.files;
    if (browser.error != null) throw StateError(browser.error!);
  }

  Future<void> create(String name) => _request(() async {
    final drive = await gateway.createGarden(name.trim());
    gardens = [...gardens, drive];
    _queueFinderSync();
    await _showDrive(drive);
  });
  Future<void> join(String code) => _request(() async {
    final drive = await gateway.joinGarden(code.trim());
    gardens = [...gardens.where((item) => item.id != drive.id), drive];
    _queueFinderSync();
    await _showDrive(drive);
  });
  Future<void> openDrive(GardenInfo drive) => _request(() async {
    if (files?.drive?.id == drive.id) {
      selected = drive;
      page = GardenPage.files;
      if (files!.path.isNotEmpty) await files!.goTo(0);
      return;
    }
    await _showDrive(drive);
  });
  Future<void> deleteDrive(GardenInfo drive) => _request(() async {
    await gateway.deleteDrive(drive.id);
    gardens = gardens.where((item) => item.id != drive.id).toList();
    _queueFinderSync();
    if (files?.drive?.id == drive.id) {
      await files!.close();
      selected = null;
      page = GardenPage.gardens;
    }
  });
  Future<void> signOut() => _request(() async {
    await _finderWork;
    await finderUpdates?.close();
    if (account != null) await finder?.signOut(account!);
    await files?.close();
    await gateway.signOut();
    account = null;
    gardens = [];
    selected = null;
    registrationPassword = '';
    registrationId = null;
    savedEmail = null;
    page = GardenPage.signIn;
  });
  Future<void> setCacheLimit(int gib) => _request(() async {
    if (gib < 1 || gib > 100) {
      throw ArgumentError('Cache limit must be between 1 and 100 GiB.');
    }
    await preferences.saveCacheLimit(gib);
    cacheLimit = gib;
  });

  void _queueFinderSync() {
    final current = account;
    if (current == null) return;
    final drives = [...gardens];
    _finderWork = _finderWork.then((_) async {
      if (account?.id != current.id) return;
      try {
        await finder?.sync(current, drives);
        await finderUpdates?.sync(current, drives);
        notifyListeners();
      } catch (failure) {
        finderUpdateError(failure);
      }
    });
  }

  void finderUpdateError(Object failure) {
    error = errorMessage(failure);
    notifyListeners();
  }

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
