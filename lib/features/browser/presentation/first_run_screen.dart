import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/presentation/settings_controller.dart';
import 'widgets/onboarding_carousel.dart';

/// The default onboarding pages shown on first launch.
const _onboardingPages = [
  OnboardingPage(
    icon: Icons.language_rounded,
    title: 'Welcome to WebBuddy',
    description:
        'A fast, privacy-focused browser built with Flutter. '
        'Browse the web with confidence.',
  ),
  OnboardingPage(
    icon: Icons.shield_rounded,
    title: 'Built-in Privacy',
    description:
        'Shields block trackers and ads automatically. '
        'Private tabs leave no trace when closed.',
  ),
  OnboardingPage(
    icon: Icons.tab_rounded,
    title: 'Powerful Tabs',
    description:
        'Open multiple tabs, switch between them instantly, '
        'and manage your browsing sessions with ease.',
  ),
  OnboardingPage(
    icon: Icons.download_rounded,
    title: 'Download Manager',
    description:
        'Track and manage your downloads in one place. '
        'Pause, resume, and open files right from the browser.',
  ),
  OnboardingPage(
    icon: Icons.tune_rounded,
    title: 'Your Browser, Your Way',
    description:
        'Choose your search engine, theme, and privacy settings. '
        'WebBuddy adapts to the way you browse.',
  ),
];

/// Full-screen first-run experience shown before the main browser.
///
/// Persists completion to [SharedPreferences] via [SettingsController]
/// so the screen is only shown once.
class FirstRunScreen extends ConsumerWidget {
  const FirstRunScreen({super.key, this.onComplete});

  /// Called after the user finishes or skips onboarding.
  final VoidCallback? onComplete;

  /// SharedPreferences key used to persist completion.
  static const onboardingCompleteKey = 'onboarding_complete';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: OnboardingCarousel(
          pages: _onboardingPages,
          onFinished: () => _completeOnboarding(ref),
        ),
      ),
    );
  }

  void _completeOnboarding(WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    storage.setBool(FirstRunScreen.onboardingCompleteKey, true);
    onComplete?.call();
  }
}
