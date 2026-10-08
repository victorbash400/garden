import 'dart:async';

import '../services/chat_gateway.dart';
import '../services/inbox_service.dart';
import 'inbox_controller.dart';

import 'package:flutter/foundation.dart';

import '../services/sharing/drive_sharing_service.dart';
import 'sharing/notification_controller.dart';

import '../utils/error_message.dart';
import '../native/account_window.dart';
import '../native/setup_links.dart';
import '../services/activity_log.dart';
import '../services/relaunch_session_gateway.dart';

import '../model/account_info.dart';
import '../model/garden_info.dart';
import '../services/garden_gateway.dart';
import '../services/account_deletion_gateway.dart';
import '../services/username_gateway.dart';
import '../services/preferences_store.dart';
import '../services/setup_store.dart';
import '../native/finder_mounts.dart';
import '../native/finder_previews.dart';
import '../native/finder_updates.dart';
import '../native/finder_status.dart';
import 'native_setup_controller.dart';
import 'files_controller.dart';
import 'account_security_controller.dart';
import 'storage_controller.dart';
import 'appearance_controller.dart';
import '../services/cache_store.dart';

enum SettingsSection {
  account,
  storage,
  connections,
  activity,
  appearance,
  drives,
  notifications,
}

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
  inbox,
}

class GardenController extends ChangeNotifier {
  GardenController(
    this.gateway,
    this.preferences, {
    this.files,
    this.appearance,
    this.accountWindow,
    this.security,
    this.finder,
    this.finderUpdates,
    this.nativeSetup,
    this.setupStore,
    this.localServer = false,
  }) : storage = preferences is CacheStore
           ? StorageController(preferences)
           : null {
    if (gateway is SharingGateway) {
      notifications = NotificationController(
        (gateway as SharingGateway).sharing,
        onAccessChanged: () => unawaited(_refreshDriveAccess()),
      );
      notifications!.addListener(notifyListeners);
    }
    accountWindow?.prepareRelaunch = _prepareRelaunch;
    if (gateway is RelaunchSessionGateway) {
      accountWindow?.exportSession = () =>
          (gateway as RelaunchSessionGateway).exportSession(account);
    }
    accountWindow?.cancelRelaunch = _cancelRelaunch;
    storage?.addListener(notifyListeners);
    appearance?.addListener(notifyListeners);
    finderUpdates?.addListener(_finderChanged);
    nativeSetup?.addListener(notifyListeners);
    files?.openFile = (node) async {
      final current = account;
      if (current == null || finder == null) {
        throw StateError('Sign in and enable Finder to open files.');
      }
      await finder!.openNode(current, node.gardenId, node.id!);
    };
    final previews = finder;
    if (previews is FinderPreviews) {
      files?.previewFile = (node) async {
        final current = account;
        if (current == null) throw StateError('Sign in to preview files.');
        await (previews as FinderPreviews).previewNode(
          current,
          node.gardenId,
          node.id!,
        );
      };
    }
  }
  Future<void> setUsername(String username) async {
    final service = gateway;
    if (service is! UsernameGateway) {
      throw StateError('Username editing is unavailable.');
    }
    final previous = account;
    final updated = await (service as UsernameGateway).setUsername(username);
    if (account?.id != previous?.id) return;
    account = updated;
    await accountWindow?.setAccount(updated);
    notifyListeners();
  }

  void reportError(Object failure) {
    error = errorMessage(failure);
    notifyListeners();
  }

  bool _relaunching = false;
  bool get relaunching => _relaunching;

  String? _prepareRelaunch() {
    if (busy ||
        finderSyncing ||
        (security?.busy ?? false) ||
        (files?.imports.busy ?? false)) {
      return 'Finish the current operation before relaunching.';
    }
    if (registrationPassword.isNotEmpty) {
      return 'Finish creating your account before relaunching.';
    }
    _relaunching = true;
    files?.imports.paused = true;
    notifyListeners();
    return null;
  }

  void _cancelRelaunch() {
    _relaunching = false;
    files?.imports.paused = false;
    notifyListeners();
  }

  NotificationController? notifications;
  InboxController? inbox;
  void openInbox() => navigate(GardenPage.inbox);
  Future<void> openInboxNotification(int drive, int? conversation) async {
    openInbox();
    await inbox!.refresh();
    final matches = inbox!.entries.where(
      (entry) =>
          entry.gardenId == drive && entry.conversationId == conversation,
    );
    if (matches.isEmpty) {
      inbox!.error = 'This conversation is no longer available.';
      notifyListeners();
      return;
    }
    await inbox!.select(matches.first);
  }

  int _accessGeneration = 0;
  final AppearanceController? appearance;
  final AccountWindow? accountWindow;
  final AccountSecurityController? security;
  final FinderMounts? finder;
  final FinderUpdates? finderUpdates;
  final NativeSetupController? nativeSetup;
  final SetupStore? setupStore;
  FinderStatus finderStatus = const FinderStatus();
  Set<int> get finderEnabledDriveIDs => finderStatus.enabled;
  bool get finderPermissionRequired => finderStatus.disabled.isNotEmpty;
  bool finderSyncing = false;
  String? finderIssue;
  bool serviceAvailable = false;
  bool setupVisible = false;

  void openSetup() {
    if (account == null) return;
    setupVisible = true;
    notifyListeners();
  }

  Future<void> closeSetup() => _request(() async {
    final current = account;
    if (current != null) await setupStore?.markSetupSeen(current.id);
    setupVisible = false;
  });

  Future<void> openSetupHelp(SetupLink link) =>
      _request(() => SetupLinks.open(link));
  final bool localServer;
  final FilesController? files;
  final GardenGateway gateway;
  final PreferencesStore preferences;
  final StorageController? storage;
  GardenPage page = GardenPage.starting;
  SettingsSection settingsSection = SettingsSection.account;
  GardenPage _settingsReturn = GardenPage.gardens;
  AccountInfo? account;
  String? savedEmail;
  List<GardenInfo> gardens = [];
  GardenInfo? selected;
  bool _busy = false;
  Future<void> _finderWork = Future.value();
  bool _changingDriveAccess = false;
  bool get busy => _relaunching || _busy || (files?.busy ?? false);
  String? error;
  int cacheLimit = 20;
  String? registrationId;
  String registrationEmail = '';
  String registrationPassword = '';

  Future<void> newAccountWindow() => _request(() async {
    final windows = accountWindow;
    if (windows == null) throw StateError('Account windows require macOS.');
    await windows.open();
  });

  Future<void> initialize() => _request(_loadStartup);

  Future<void> _loadStartup() async {
    await appearance?.load();
    if (appearance?.error != null) throw StateError(appearance!.error!);
    await nativeSetup?.refresh();
    cacheLimit = await preferences.readCacheLimit();
    final sessionError = accountWindow?.sessionError;
    if (sessionError != null) throw StateError(sessionError);
    if (gateway is RelaunchSessionGateway) {
      final restored = await (gateway as RelaunchSessionGateway)
          .restoreRelaunch();
      if (restored != null) {
        await _finishAuthentication(restored);
        return;
      }
    }
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
    setupVisible = false;
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
    setupVisible = true;
  });

  Future<void> resendVerification() => _request(() async {
    if (registrationEmail.isEmpty) {
      throw StateError('Registration has not started.');
    }
    registrationId = await gateway.beginRegistration(registrationEmail);
  });

  Future<void> _refreshDriveAccess() async {
    final current = account;
    if (current == null || _changingDriveAccess) return;
    final generation = ++_accessGeneration;
    try {
      final latest = await gateway.listGardens();
      if (account?.id != current.id || generation != _accessGeneration) return;
      gardens = latest;
      final active = files?.drive;
      if (active != null) {
        final matches = latest.where((item) => item.id == active.id);
        if (matches.isEmpty) {
          await files?.close();
          if (account?.id != current.id || generation != _accessGeneration) {
            return;
          }
          selected = null;
          if (page == GardenPage.files) page = GardenPage.gardens;
        } else {
          files?.drive = matches.single;
          selected = matches.single;
        }
      }
      _queueFinderSync();
      notifyListeners();
    } catch (failure) {
      if (account?.id == current.id && generation == _accessGeneration) {
        error = errorMessage(failure);
        notifyListeners();
      }
    }
  }

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
    await accountWindow?.setAccount(signedIn);
    inbox?.removeListener(notifyListeners);
    inbox?.dispose();
    inbox = gateway is ChatGateway
        ? InboxController(
            ServerpodInboxService((gateway as ChatGateway).client),
            ServerpodChatService((gateway as ChatGateway).client),
            signedIn.id,
          )
        : null;
    inbox?.addListener(notifyListeners);
    account = signedIn;
    ActivityLog.instance.account = signedIn.id;
    savedEmail = signedIn.email;
    page = GardenPage.starting;
    gardens = await gateway.listGardens();
    serviceAvailable = true;
    setupVisible =
        gardens.isEmpty &&
        setupStore != null &&
        !await setupStore!.hasSeenSetup(signedIn.id);
    page = GardenPage.gardens;
    _queueFinderSync();
    if (notifications != null) unawaited(notifications!.start());
    if (inbox != null) unawaited(inbox!.start());
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
          finderIssue != null ||
          (!finderSyncing &&
              (finderStatus.disconnected.isNotEmpty ||
                  finderStatus.registered.isNotEmpty &&
                      nativeSetup?.status?.finderAvailable == false)));

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
  Future<void> renameDrive(GardenInfo drive, String name) => _request(() async {
    await gateway.renameDrive(drive.id, name.trim());
    final renamed = GardenInfo(
      id: drive.id,
      name: name.trim(),
      role: drive.role,
      members: drive.members,
    );
    gardens = gardens
        .map((item) => item.id == drive.id ? renamed : item)
        .toList();
    if (selected?.id == drive.id) selected = renamed;
    if (files?.drive?.id == drive.id) files!.drive = renamed;
    ActivityLog.instance.record(drive.id, renamed.name, 'Rename drive');
    _queueFinderSync();
  });

  Future<void> deleteDrive(GardenInfo drive) => _request(() async {
    final current = account;
    if (current == null || drive.role != 'Owner') {
      throw StateError('Only the drive owner can delete this drive.');
    }
    _changingDriveAccess = true;
    try {
      if (files?.imports.driveId == drive.id) {
        await files!.imports.cancelAndWait();
      }
      await _finderWork;
      final kept = gardens.where((item) => item.id != drive.id).toList();
      await finder?.sync(current, kept);
      await gateway.deleteDrive(drive.id);
      gardens = kept;
      if (files?.drive?.id == drive.id) {
        await files!.close();
        selected = null;
        page = GardenPage.gardens;
      }
    } finally {
      _changingDriveAccess = false;
    }
    _queueFinderSync();
  });
  Future<void> signOut() => _request(() => _endSession());

  Future<void> deleteAccount(String email) async {
    if (busy) throw StateError('Another account action is in progress.');
    if (gateway is! AccountDeletionGateway) {
      throw StateError('Account deletion is unavailable.');
    }
    _busy = true;
    notifyListeners();
    try {
      await _endSession(deletingEmail: email);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> _endSession({String? deletingEmail}) async {
    _accessGeneration++;
    _changingDriveAccess = true;
    try {
      await _finderWork;
      final current = account;
      final disconnect = await accountWindow?.releaseAccount() ?? true;
      if (current != null && (disconnect || deletingEmail != null)) {
        await finder?.signOut(current);
      }
      await finderUpdates?.close();
      await files?.close();
      await inbox?.close();
      await notifications?.close();
      if (deletingEmail != null) {
        await (gateway as AccountDeletionGateway).deleteAccount(deletingEmail);
      } else {
        await gateway.signOut();
      }
      account = null;
      setupVisible = false;
      ActivityLog.instance.account = null;
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
    } catch (_) {
      final current = account;
      if (current != null) await accountWindow?.setAccount(current);
      rethrow;
    } finally {
      _changingDriveAccess = false;
    }
  }

  Future<void> setCacheLimit(int gib) => _request(() async {
    if (gib < 0 || gib > 100) {
      throw ArgumentError('Cache limit must be between 0 and 100 GiB.');
    }
    if (storage != null) {
      await storage!.setLimit(gib);
      if (storage!.error != null) throw StateError(storage!.error!);
    } else {
      await preferences.saveCacheLimit(gib);
    }
    cacheLimit = gib;
  });

  Future<void> handleSystemWake() async {
    if (account == null || _changingDriveAccess) return;
    _queueFinderSync(restart: true);
    await _finderWork;
    if (files?.drive != null) await files!.reconnect();
  }

  void _queueFinderSync({bool restart = false}) {
    final current = account;
    if (current == null || _changingDriveAccess) return;
    finderSyncing = true;
    notifyListeners();
    _finderWork = _finderWork.then((_) async {
      try {
        if (account?.id != current.id || _changingDriveAccess) return;
        final drives = gardens.toList();
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

  void _finderChanged() {
    final status = finderUpdates?.status;
    if (status != null) finderStatus = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _accessGeneration++;
    notifications?.removeListener(notifyListeners);
    notifications?.dispose();
    inbox?.removeListener(notifyListeners);
    inbox?.dispose();
    appearance?.removeListener(notifyListeners);
    appearance?.dispose();
    storage?.removeListener(notifyListeners);
    storage?.dispose();
    finderUpdates?.removeListener(_finderChanged);
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
