import 'package:flutter/material.dart';
import 'package:web_buddy/features/bookmarks/presentation/pages/bookmarks_page.dart';
import 'package:web_buddy/features/browser/presentation/pages/browser_page.dart';
import 'package:web_buddy/features/downloads/presentation/pages/downloads_page.dart';
import 'package:web_buddy/features/history/presentation/pages/history_page.dart';
import 'package:web_buddy/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:web_buddy/features/settings/presentation/pages/settings_page.dart';
import 'package:web_buddy/features/tabs/presentation/pages/tab_switcher_page.dart';

/// Simple named-route based navigation.
///
/// Using Navigator 1.0 for simplicity in the initial implementation.
/// GoRouter can be substituted for deep linking / URL-based navigation
/// when web platform support is added.
class AppRouter {
  static const String browser = '/';
  static const String tabs = '/tabs';
  static const String bookmarks = '/bookmarks';
  static const String history = '/history';
  static const String downloads = '/downloads';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case browser:
        return MaterialPageRoute(builder: (_) => const BrowserPage());
      case tabs:
        return MaterialPageRoute(builder: (_) => const TabSwitcherPage());
      case bookmarks:
        return MaterialPageRoute(builder: (_) => const BookmarksPage());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryPage());
      case downloads:
        return MaterialPageRoute(builder: (_) => const DownloadsPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      default:
        return MaterialPageRoute(builder: (_) => const BrowserPage());
    }
  }
}
