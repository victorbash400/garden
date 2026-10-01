import 'package:flutter/material.dart';

import '../state/garden_controller.dart';
import '../components/error_notice.dart';
import '../components/garden_sidebar.dart';
import '../components/settings/settings_sidebar.dart';
import '../components/settings/settings_transition.dart';
import '../views/account_form.dart';
import '../views/files_view.dart';
import '../views/gardens_view.dart';
import '../views/settings_view.dart';
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
    home: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        body: Row(
          children: [
            if (controller.account != null)
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
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: ErrorNotice(
                        message: controller.error!,
                        onDismiss: () => controller.navigate(controller.page),
                      ),
                    ),
                  Expanded(
                    child: SettingsTransition(
                      enabled: controller.account != null,
                      child: KeyedSubtree(
                        key: ValueKey(controller.page),
                        child: _content(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _content() => switch (controller.page) {
    GardenPage.welcome => WelcomeView(
      onSignIn: () => controller.navigate(GardenPage.signIn),
      onRegister: () => controller.navigate(GardenPage.register),
    ),
    GardenPage.signIn => Center(
      child: AccountForm(
        key: const ValueKey('signin'),
        savedEmail: controller.savedEmail,
        onContinueSaved: controller.continueSavedLogin,
        onForgetSaved: controller.forgetSavedLogin,
        remember: controller.rememberLogin,
        onRememberChanged: controller.setRememberLogin,
        showDemo: true,
        onCreateAccount: () => controller.navigate(GardenPage.register),
        busy: controller.busy,
        submitLabel: 'Sign in',
        onSubmit: controller.signIn,
      ),
    ),
    GardenPage.register => Center(
      child: AccountForm(
        key: const ValueKey('register'),
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
    ),
    GardenPage.settings => SettingsView(controller: controller),
  };
}
