import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/utils/platform_utils.dart';
import 'package:web_buddy/features/browser/presentation/widgets/browser_toolbar.dart';
import 'package:web_buddy/features/browser/presentation/widgets/web_view_container.dart';
import 'package:web_buddy/features/browser/presentation/widgets/tab_bar_strip.dart';
import 'package:web_buddy/features/tabs/presentation/providers/tab_provider.dart';

/// The main browser page showing the WebView and toolbar.
class BrowserPage extends ConsumerStatefulWidget {
  const BrowserPage({super.key});

  @override
  ConsumerState<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends ConsumerState<BrowserPage> {
  @override
  Widget build(BuildContext context) {
    final session = ref.watch(browserSessionProvider);
    final activeTab = session.activeTab;
    final isDesktop = PlatformUtils.isDesktop;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Desktop-style tab bar
            if (isDesktop) const TabBarStrip(),

            // Toolbar with address bar & controls
            const BrowserToolbar(),

            // Loading progress indicator
            if (activeTab != null && activeTab.isLoading)
              LinearProgressIndicator(
                value: activeTab.loadProgress > 0
                    ? activeTab.loadProgress
                    : null,
                minHeight: 2,
              ),

            // WebView area
            Expanded(
              child: activeTab != null
                  ? WebViewContainer(
                      key: ValueKey(activeTab.id),
                      tabId: activeTab.id,
                    )
                  : const _EmptyTabView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTabView extends StatelessWidget {
  const _EmptyTabView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to WebBuddy',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a URL or search to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
