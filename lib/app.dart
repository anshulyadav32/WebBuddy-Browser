import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/theme.dart';
import 'features/browser/presentation/first_run_screen.dart';
import 'features/home/presentation/browser_home_screen.dart';
import 'features/settings/presentation/settings_controller.dart';

class WebBuddyApp extends ConsumerWidget {
  const WebBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final storage = ref.watch(storageServiceProvider);
    final onboardingDone =
        storage.getBool(FirstRunScreen.onboardingCompleteKey) ?? false;

    final router = GoRouter(
      initialLocation: onboardingDone ? '/' : '/onboarding',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const BrowserHomeScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => FirstRunScreen(
            onComplete: () => GoRouter.of(context).go('/'),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'WebBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
