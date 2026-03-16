import 'package:flutter/material.dart';

/// Phase 1 home screen — the entry point when the app launches.
class BrowserHomeScreen extends StatelessWidget {
  const BrowserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / icon
                Icon(Icons.public, size: 72, color: cs.primary),
                const SizedBox(height: 16),

                // App name
                Text(
                  'WebBuddy',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Privacy-First Browser',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Foundation-ready card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: cs.tertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Phase 1 Foundation Ready',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Project architecture, models, services, '
                          'routing, and theming are set up.\n'
                          'WebView and tab management coming in Phase 2.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick-info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: const [
                    _InfoChip(label: 'Riverpod'),
                    _InfoChip(label: 'GoRouter'),
                    _InfoChip(label: 'SharedPrefs'),
                    _InfoChip(label: 'Light / Dark'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: Icon(
        Icons.check,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
