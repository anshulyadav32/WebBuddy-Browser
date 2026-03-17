import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstRunScreen extends StatefulWidget {
  static const String onboardingCompleteKey = 'onboardingComplete';
  final VoidCallback? onComplete;

  const FirstRunScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  State<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends State<FirstRunScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      title: 'Welcome to WebBuddy',
      description: 'A fast, private browser built with Flutter.',
      icon: Icons.public,
    ),
    _OnboardingPage(
      title: 'Built-in Privacy',
      description: 'Block trackers and ads automatically.',
      icon: Icons.shield,
    ),
    _OnboardingPage(
      title: 'Smart Search',
      description: 'Quick search with your favourite engine.',
      icon: Icons.search,
    ),
    _OnboardingPage(
      title: 'Tab Management',
      description: 'Organise your tabs with ease.',
      icon: Icons.tab,
    ),
    _OnboardingPage(
      title: "You're All Set!",
      description: 'Start browsing with WebBuddy.',
      icon: Icons.check_circle,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(FirstRunScreen.onboardingCompleteKey, true);
    widget.onComplete?.call();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(page.icon, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        page.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(page.description, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLast)
                  TextButton(onPressed: _finish, child: const Text('Skip'))
                else
                  const SizedBox.shrink(),
                if (!isLast)
                  ElevatedButton(onPressed: _next, child: const Text('Next'))
                else
                  ElevatedButton(
                    onPressed: _finish,
                    child: const Text('Get Started'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });
}
