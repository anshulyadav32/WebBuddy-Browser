import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/constants/search_engines.dart';

/// Onboarding flow shown on first launch.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(theme: theme),
                  _PrivacyPage(theme: theme),
                  _SearchEnginePage(theme: theme),
                ],
              ),
            ),
            // Page indicator & controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: () => _finish(),
                    child: const Text('Skip'),
                  ),
                  // Dots
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Next/Done button
                  FilledButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                    child: Text(_currentPage < 2 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed('/');
  }
}

class _WelcomePage extends StatelessWidget {
  final ThemeData theme;

  const _WelcomePage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'Welcome to WebBuddy',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'A fast, private, and modern web browser built for you.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  final ThemeData theme;

  const _PrivacyPage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield, size: 80, color: Colors.green),
          const SizedBox(height: 32),
          Text(
            'Privacy by Default',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
              'Ad blocking and tracker protection are enabled by default.\n\n'
              '• Blocks ads and trackers\n'
              '• Upgrades connections to HTTPS\n'
              '• Third-party cookies blocked\n'
              '• Per-site privacy controls',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SearchEnginePage extends StatelessWidget {
  final ThemeData theme;

  const _SearchEnginePage({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'Choose Your Search Engine',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...SearchEngines.engines.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(entry.value.name),
                onTap: () {
                  // Selection handled on completion
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
