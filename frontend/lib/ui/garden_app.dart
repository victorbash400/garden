import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import '../components/error_notice.dart';
import '../components/build_update_banner.dart';
import '../components/finder_status_observer.dart';
import '../components/files/import_status_bar.dart';
import '../components/garden_sidebar.dart';
import '../components/garden_menu_bar.dart';
import '../components/settings/settings_sidebar.dart';
import '../components/settings/settings_transition.dart';
import '../views/account_form.dart';
import '../views/files_view.dart';
import '../views/gardens_view.dart';
import '../views/settings_view.dart';
import '../views/startup_view.dart';
import '../views/value_form.dart';
import '../views/verification_view.dart';
import '../views/welcome_view.dart';
import 'garden_theme.dart';

class GardenApp extends StatelessWidget {
  const GardenApp({super.key, required this.controller});
  final GardenController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Garden',
    debugShowCheckedModeBanner: false,
    theme: GardenTheme.light,
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
                                  onDismiss: () =>
                                      controller.navigate(controller.page),
                                ),
                              ),
                            Expanded(
                              child: SettingsTransition(
                                enabled: _showSidebar,
                                child: KeyedSubtree(
                                  key: ValueKey(controller.page),
                                  child: _content(),
                                ),
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
                    child: BuildUpdateBanner(window: controller.accountWindow!),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  bool get _showSidebar =>
      controller.account != null &&
      const {
        GardenPage.gardens,
        GardenPage.create,
        GardenPage.join,
        GardenPage.files,
        GardenPage.settings,
      }.contains(controller.page);

  Widget _content() => switch (controller.page) {
    GardenPage.starting => StartupView(
      error: controller.error,
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
      controller: controller.files!,
      userId: controller.account!.id,
      onBackToDrives: controller.back,
      onConnections: controller.needsFinderAttention
          ? controller.openConnections
          : null,
    ),
    GardenPage.settings => SettingsView(controller: controller),
  };
}
