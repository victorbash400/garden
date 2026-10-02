import 'package:flutter/foundation.dart';

import '../utils/error_message.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/preferences_store.dart';
import '../native/finder_mounts.dart';
import '../native/mac_finder_updates.dart';
import 'files_controller.dart';
import 'account_security_controller.dart';

enum SettingsSection { account, storage, connections }

enum GardenPage {
  starting,
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
  final FinderMounts? finder;
  final MacFinderUpdates? finderUpdates;
  Set<int> finderEnabledDriveIDs = {};
  bool finderPermissionRequired = false;
  bool finderSyncing = false;
  String? finderIssue;
  bool serviceAvailable = false;
  final bool localServer;
  final FilesController? files;
  final GardenGateway gateway;
  final PreferencesStore preferences;
  GardenPage page = GardenPage.starting;
  SettingsSection settingsSection = SettingsSection.account;
  GardenPage _settingsReturn = GardenPage.gardens;
  AccountInfo? account;
  String? savedEmail;
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

  Future<void> initialize() => _request(_loadStartup);

  Future<void> _loadStartup() async {
    cacheLimit = await preferences.readCacheLimit();
    savedEmail = await gateway.savedLogin();
    await security?.checkConfiguration();
    if (savedEmail == null || security?.touchId == true) {
      page = GardenPage.signIn;
      return;
    }
    final restored = await gateway.restoreAccount();
    if (restored == null) {
      await gateway.forgetSavedLogin();
      savedEmail = null;
      page = GardenPage.signIn;
      return;
    }
    await _finishAuthentication(restored);
  }

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

  Future<void> continueSavedLogin() => _request(() async {
    final restored = await gateway.restoreAccount();
    if (restored == null) {
      await gateway.forgetSavedLogin();
      savedEmail = null;
      throw StateError('Saved login expired. Sign in again.');
    }
    await _finishAuthentication(restored);
  });
  Future<void> forgetSavedLogin() => _request(() async {
    await gateway.forgetSavedLogin();
    savedEmail = null;
  });
  Future<void> signIn(String email, String password) => _request(() async {
    final signedIn = await gateway.signIn(
      email.trim(),
      password,
      remember: true,
    );
    await _finishAuthentication(signedIn);
  });

  Future<void> signInWithPasskey() => _request(() async {
    final auth = security;
    if (auth == null) throw StateError('Passkeys are unavailable.');
    final signedIn = await auth.gateway.signInWithPasskey(remember: true);
    await _finishAuthentication(signedIn);
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
    final signedIn = await gateway.finishRegistration(
      id,
      code.trim(),
      registrationPassword,
    );
    registrationPassword = '';
    registrationId = null;
    await _finishAuthentication(signedIn);
  });

  Future<void> resendVerification() => _request(() async {
    if (registrationEmail.isEmpty) {
      throw StateError('Registration has not started.');
    }
    registrationId = await gateway.beginRegistration(registrationEmail);
  });

  Future<void> refresh() => _request(() async {
    try {
      gardens = await gateway.listGardens();
      serviceAvailable = true;
    } catch (_) {
      serviceAvailable = false;
      rethrow;
    }
    _queueFinderSync();
  });

  Future<void> checkConnections() => _request(() async {
    try {
      gardens = await gateway.listGardens();
      serviceAvailable = true;
    } catch (_) {
      serviceAvailable = false;
      rethrow;
    }
    _queueFinderSync();
    await _finderWork;
  });

  Future<void> _finishAuthentication(AccountInfo signedIn) async {
    account = signedIn;
    savedEmail = signedIn.email;
    page = GardenPage.starting;
    gardens = await gateway.listGardens();
    serviceAvailable = true;
    page = GardenPage.gardens;
    _queueFinderSync();
  }

  Future<void> retryLoading() => _request(() async {
    final signedIn = account;
    if (signedIn == null) {
      await _loadStartup();
      return;
    }
    await _finishAuthentication(signedIn);
  });

  Future<void> checkFinder() => _request(() async {
    await _finderWork;
    final signedIn = account;
    if (signedIn == null) throw StateError('Sign in first.');
    finderEnabledDriveIDs = await finder?.enabled(signedIn, gardens) ?? {};
    finderPermissionRequired =
        await finder?.permissionRequired(signedIn, gardens) ?? false;
  });

  Future<void> openInFinder(GardenInfo drive) => _request(() async {
    final signedIn = account;
    if (signedIn == null || finder == null) {
      throw StateError('Finder is unavailable.');
    }
    await finder!.open(signedIn, drive.id);
  });

  Future<void> openFinderSettings() => _request(() async {
    if (finder == null) throw StateError('Finder is unavailable.');
    await finder!.openSettings();
  });

  bool get needsFinderAttention =>
      account != null &&
      (!serviceAvailable ||
          (finder != null &&
              !finderSyncing &&
              (finderIssue != null ||
                  gardens
                      .map((drive) => drive.id)
                      .toSet()
                      .difference(finderEnabledDriveIDs)
                      .isNotEmpty)));

  void openConnections() {
    selectSettings(SettingsSection.connections);
    navigate(GardenPage.settings);
  }

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
    finderEnabledDriveIDs.remove(drive.id);
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
    finderEnabledDriveIDs = {};
    finderPermissionRequired = false;
    finderSyncing = false;
    finderIssue = null;
    serviceAvailable = false;
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
    final drives = gardens.toList();
    finderSyncing = true;
    notifyListeners();
    _finderWork = _finderWork.then((_) async {
      if (account?.id != current.id) return;
      try {
        await finder?.sync(current, drives);
        finderEnabledDriveIDs = await finder?.enabled(current, drives) ?? {};
        finderPermissionRequired =
            await finder?.permissionRequired(current, drives) ?? false;
        await finderUpdates?.sync(current, drives);
        finderIssue = null;
      } catch (failure) {
        finderUpdateError(failure);
      } finally {
        finderSyncing = false;
        notifyListeners();
      }
    });
  }

  void finderUpdateError(Object failure) {
    finderIssue = errorMessage(failure);
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
