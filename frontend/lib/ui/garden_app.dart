import 'package:flutter/material.dart';

import '../views/inbox_view.dart';
import '../components/setup/setup_modal.dart';
import '../components/window_appearance.dart';

import '../services/chat_gateway.dart';
import '../services/sharing/drive_sharing_service.dart';
import '../components/sharing/invite_member_dialog.dart';

import '../state/garden_controller.dart';
import '../components/error_notice.dart';
import '../components/account_background.dart';
import '../components/build_update_banner.dart';
import '../components/finder_status_observer.dart';
import '../components/files/import_status_bar.dart';
import '../components/garden_sidebar.dart';
import '../components/garden_menu_bar.dart';
import '../components/settings/settings_sidebar.dart';
import '../views/account_form.dart';
import '../views/files_view.dart';
import '../views/gardens_view.dart';
import '../views/settings_view.dart';
import '../views/startup_view.dart';
import '../views/value_form.dart';
import '../views/verification_view.dart';
import '../views/welcome_view.dart';
import 'garden_theme.dart';
import 'garden_scroll_behavior.dart';
import '../model/appearance/theme_presets.dart';

class GardenApp extends StatelessWidget {
  const GardenApp({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MaterialApp(
      title: 'Garden',
      scrollBehavior: const GardenScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: _showSidebar
          ? GardenTheme.profile(
              controller.appearance?.light ?? lightPresets.first,
              Brightness.light,
            )
          : GardenTheme.light,
      darkTheme: _showSidebar
          ? GardenTheme.profile(
              controller.appearance?.dark ?? darkPresets.first,
              Brightness.dark,
            )
          : GardenTheme.light,
      themeMode: _showSidebar
          ? controller.appearance?.mode ?? ThemeMode.light
          : ThemeMode.light,
      themeAnimationDuration: Duration.zero,
      builder: (context, child) => WindowAppearance(
        window: controller.accountWindow,
        onError: controller.reportError,
        child: child!,
      ),
      home: GardenMenuBar(
        controller: controller,
        child: FinderStatusObserver(
          controller: controller,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) => Scaffold(
              body: Stack(
                children: [
                  AbsorbPointer(
                    absorbing: controller.relaunching,
                    child: Row(
                      children: [
                        if (_showSidebar)
                          AnimatedSize(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.centerLeft,
                            child: controller.page == GardenPage.settings
                                ? SettingsSidebar(controller: controller)
                                : GardenSidebar(controller: controller),
                          ),
                        Expanded(
                          child: Column(
                            children: [
                              if (controller.error != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                  ),
                                  child: ErrorNotice(
                                    message: controller.error!,
                                    dismissLabel: controller.sessionExpired
                                        ? 'Sign in'
                                        : 'OK',
                                    canDismiss: !controller.sessionExpired,
                                    onDismiss: controller.sessionExpired
                                        ? controller.acknowledgeSessionExpiry
                                        : () => controller.navigate(
                                            controller.page,
                                          ),
                                  ),
                                ),
                              Expanded(
                                child: KeyedSubtree(
                                  key: ValueKey(controller.page),
                                  child: _showAccountBackground
                                      ? AccountBackground(
                                          child: _content(context),
                                        )
                                      : _content(context),
                                ),
                              ),
                              if (controller.files != null)
                                ImportStatusBar(
                                  controller: controller.files!.imports,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_showSidebar && controller.accountWindow != null)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      width: 240,
                      child: BuildUpdateBanner(
                        window: controller.accountWindow!,
                        onDark: _showAccountBackground,
                      ),
                    ),
                  if (controller.setupVisible && controller.account != null)
                    Positioned.fill(child: SetupModal(controller: controller)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  bool get _showAccountBackground => const {
    GardenPage.signIn,
    GardenPage.register,
    GardenPage.verify,
  }.contains(controller.page);

  bool get _showSidebar =>
      controller.account != null &&
      const {
        GardenPage.gardens,
        GardenPage.create,
        GardenPage.join,
        GardenPage.files,
        GardenPage.settings,
        GardenPage.inbox,
      }.contains(controller.page);

  Widget _content(BuildContext context) => switch (controller.page) {
    GardenPage.starting => StartupView(
      loading: controller.busy,
      onRetry: controller.retryLoading,
      onSignIn: () => controller.navigate(GardenPage.signIn),
    ),
    GardenPage.welcome => WelcomeView(
      onSignIn: () => controller.navigate(GardenPage.signIn),
      onRegister: () => controller.navigate(GardenPage.register),
    ),
    GardenPage.signIn => Center(
      child: AccountForm(
        key: const ValueKey('signin'),
        security: controller.security,
        onPasskey: controller.security == null
            ? null
            : controller.signInWithPasskey,
        savedEmail: controller.savedEmail,
        onContinueSaved: controller.continueSavedLogin,
        onForgetSaved: controller.forgetSavedLogin,
        showDemo: controller.localServer,
        onCreateAccount: () => controller.navigate(GardenPage.register),
        busy: controller.busy,
        submitLabel: 'Sign in',
        onSubmit: controller.signIn,
      ),
    ),
    GardenPage.register => Center(
      child: AccountForm(
        key: const ValueKey('register'),
        isRegistration: true,
        busy: controller.busy,
        submitLabel: 'Create account',
        onSubmit: controller.register,
        onBack: controller.back,
      ),
    ),
    GardenPage.verify => VerificationView(controller: controller),
    GardenPage.gardens => GardensView(controller: controller),
    GardenPage.create => Center(
      child: ValueForm(
        key: const ValueKey('create'),
        label: 'Drive name',
        action: 'Create drive',
        busy: controller.busy,
        onSubmit: controller.create,
        onBack: controller.back,
      ),
    ),
    GardenPage.join => Center(
      child: ValueForm(
        key: const ValueKey('join'),
        label: 'Invitation code',
        action: 'Join drive',
        busy: controller.busy,
        onSubmit: controller.join,
        onBack: controller.back,
      ),
    ),
    GardenPage.files => FilesView(
      key: ValueKey(controller.account!.id),
      controller: controller.files!,
      chatService: controller.gateway is ChatGateway
          ? ServerpodChatService((controller.gateway as ChatGateway).client)
          : null,
      focusEvents: controller.accountWindow?.focusEvents,
      userId: controller.account!.id,
      onBackToDrives: controller.back,
      onInbox: controller.openInbox,
      inboxUnread: controller.inbox?.unread,
      onManageDrive: controller.gateway is SharingGateway
          ? () {
              showDialog<void>(
                context: context,
                builder: (_) => InviteMemberDialog(
                  service: (controller.gateway as SharingGateway).sharing,
                  driveId: controller.files!.drive!.id,
                  owner: controller.files!.drive!.role == 'Owner',
                ),
              );
            }
          : null,
      onConnections: controller.needsFinderAttention
          ? controller.openConnections
          : null,
    ),
    GardenPage.settings => SettingsView(controller: controller),
    GardenPage.inbox => InboxView(controller: controller),
  };
}
