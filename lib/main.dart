import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/router/app_router.dart';
import 'package:web_buddy/core/theme/app_theme.dart';
import 'package:web_buddy/core/utils/logger.dart';
import 'package:web_buddy/features/privacy/presentation/providers/privacy_provider.dart';
import 'package:web_buddy/features/settings/domain/entities/browser_settings.dart'
    as app_settings;
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();

  runApp(
    const ProviderScope(
      child: WebBuddyApp(),
    ),
  );
}

class WebBuddyApp extends ConsumerWidget {
  const WebBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize filter lists
    ref.watch(filterListInitProvider);

    final settings = ref.watch(settingsProvider);
    final themeMode = _mapThemeMode(settings.themeMode);

    return MaterialApp(
      title: 'WebBuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRouter.browser,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }

  ThemeMode _mapThemeMode(app_settings.ThemeMode mode) {
    switch (mode) {
      case app_settings.ThemeMode.light:
        return ThemeMode.light;
      case app_settings.ThemeMode.dark:
        return ThemeMode.dark;
      case app_settings.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
