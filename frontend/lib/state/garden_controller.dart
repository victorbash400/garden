import 'package:flutter/foundation.dart';

import '../utils/error_message.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/preferences_store.dart';
import '../native/finder_mounts.dart';
import '../native/finder_updates.dart';
import '../native/finder_status.dart';
import 'native_setup_controller.dart';
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
    this.nativeSetup,
    this.localServer = false,
  }) {
    finderUpdates?.addListener(notifyListeners);
    nativeSetup?.addListener(notifyListeners);
    files?.openFile = (node) async {
      final current = account;
      if (current == null || finder == null) {
        throw StateError('Sign in and enable Finder to open files.');
      }
      await finder!.openNode(current, node.gardenId, node.id!);
    };
  }
  final AccountSecurityController? security;
  final FinderMounts? finder;
  final FinderUpdates? finderUpdates;
  final NativeSetupController? nativeSetup;
  FinderStatus finderStatus = const FinderStatus();
  Set<int> get finderEnabledDriveIDs => finderStatus.enabled;
  bool get finderPermissionRequired => finderStatus.disabled.isNotEmpty;
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
    await nativeSetup?.refresh();
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
    await nativeSetup?.refresh();
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
    await nativeSetup?.refresh();
    finderStatus =
        await finder?.status(signedIn, gardens) ?? const FinderStatus();
    if (finderUpdates?.state == FinderUpdateState.disconnected) {
      await finderUpdates!.sync(signedIn, gardens);
    }
    if (files?.drive != null && files?.live == false) {
      await files!.reconnect();
    }
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
          nativeSetup?.needsAttention == true ||
          finderUpdates?.error != null ||
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
  Future<void> openDrive(GardenInfo drive, {bool root = false}) =>
      _request(() async {
        if (files?.drive?.id == drive.id) {
          selected = drive;
          page = GardenPage.files;
          if (root) await files!.goTo(0);
          return;
        }
        await _showDrive(drive);
        if (root) await files!.goTo(0);
      });
  Future<void> deleteDrive(GardenInfo drive) => _request(() async {
    if (files?.imports.driveId == drive.id) {
      await files!.imports.cancelAndWait();
    }
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
    finderStatus = const FinderStatus();
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

  Future<void> handleSystemWake() async {
    if (account == null) return;
    _queueFinderSync(restart: true);
    await _finderWork;
    if (files?.drive != null) await files!.reconnect();
  }

  void _queueFinderSync({bool restart = false}) {
    final current = account;
    if (current == null) return;
    final drives = gardens.toList();
    finderSyncing = true;
    notifyListeners();
    _finderWork = _finderWork.then((_) async {
      if (account?.id != current.id) return;
      try {
        if (restart) await finderUpdates?.close();
        await finder?.sync(current, drives);
        finderStatus =
            await finder?.status(current, drives) ?? const FinderStatus();
        finderIssue = null;
        await finderUpdates?.sync(current, drives);
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

  @override
  void dispose() {
    finderUpdates?.removeListener(notifyListeners);
    nativeSetup?.removeListener(notifyListeners);
    super.dispose();
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
