import 'package:flutter/material.dart';

/// A multi-page onboarding carousel with dot indicators and
/// swipe / next navigation.
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    required this.pages,
    this.onFinished,
  });

  final List<OnboardingPage> pages;
  final VoidCallback? onFinished;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == widget.pages.length - 1;

  void _next() {
    if (_isLastPage) {
      widget.onFinished?.call();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Page content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final page = widget.pages[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        page.icon,
                        size: 48,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      page.description,
                      style: textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Dot indicators
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? cs.primary
                      : cs.primary.withAlpha(60),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // Navigation buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _isLastPage ? null : _skip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: _isLastPage
                        ? cs.onSurface.withAlpha(60)
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton(
                onPressed: _next,
                child: Text(_isLastPage ? 'Get Started' : 'Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Data model for a single onboarding page.
class OnboardingPage {
  const OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
