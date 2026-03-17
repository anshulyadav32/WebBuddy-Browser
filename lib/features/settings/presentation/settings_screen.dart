import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/clear_browsing_data_service.dart';
import '../domain/browser_settings.dart';
import 'settings_controller.dart';
import 'site_settings_controller.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_select_tile.dart';
import 'widgets/settings_toggle_tile.dart';

/// Full-page settings screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Appearance ───────────────────────────────────────────
          SettingsSection(
            title: 'Appearance',
            children: [
              SettingsSelectTile<ThemeMode>(
                icon: Icons.brightness_6,
                title: 'Theme',
                value: settings.themeMode,
                options: ThemeMode.values,
                labelOf: (m) => switch (m) {
                  ThemeMode.system => 'System',
                  ThemeMode.light => 'Light',
                  ThemeMode.dark => 'Dark',
                },
                onChanged: controller.setThemeMode,
              ),
            ],
          ),

          // ── Search ───────────────────────────────────────────────
          SettingsSection(
            title: 'Search',
            children: [
              SettingsSelectTile<SearchEngine>(
                icon: Icons.search,
                title: 'Search engine',
                value: settings.searchEngine,
                options: SearchEngine.values,
                labelOf: (e) => e.label,
                onChanged: controller.setSearchEngine,
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Default home page'),
                subtitle: Text(
                  settings.homePage.isEmpty
                      ? 'https://google.com'
                      : settings.homePage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showHomePageDialog(context, controller, settings),
              ),
            ],
          ),

          // ── Content ──────────────────────────────────────────────
          SettingsSection(
            title: 'Content',
            children: [
              SettingsToggleTile(
                icon: Icons.code,
                title: 'JavaScript',
                subtitle: 'Disabling breaks most websites',
                value: settings.javaScriptEnabled,
                onChanged: controller.setJavaScriptEnabled,
              ),
              SettingsToggleTile(
                icon: Icons.cached,
                title: 'Use cache',
                subtitle: 'When off, pages are loaded fresh more often',
                value: settings.cacheEnabled,
                onChanged: controller.setCacheEnabled,
              ),
              SettingsToggleTile(
                icon: Icons.swap_vert,
                title: 'Show scrollbars',
                value: settings.scrollbarsEnabled,
                onChanged: controller.setScrollbarsEnabled,
              ),
              ListTile(
                leading: const Icon(Icons.smart_toy_outlined),
                title: const Text('Custom user-agent'),
                subtitle: Text(
                  settings.customUserAgent.isEmpty
                      ? 'Using default WebView user-agent'
                      : settings.customUserAgent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    _showUserAgentDialog(context, controller, settings),
              ),
              SettingsToggleTile(
                icon: Icons.block,
                title: 'Block pop-ups',
                value: settings.popUpBlockingEnabled,
                onChanged: controller.setPopUpBlockingEnabled,
              ),
              SettingsSelectTile<CookiePolicy>(
                icon: Icons.cookie,
                title: 'Cookie policy',
                value: settings.cookiePolicy,
                options: CookiePolicy.values,
                labelOf: (p) => p.label,
                onChanged: controller.setCookiePolicy,
              ),
            ],
          ),

          // ── Security ─────────────────────────────────────────────
          SettingsSection(
            title: 'Security',
            children: [
              SettingsToggleTile(
                icon: Icons.lock,
                title: 'HTTPS upgrade',
                subtitle: 'Automatically upgrade HTTP to HTTPS',
                value: settings.httpsUpgradeEnabled,
                onChanged: controller.setHttpsUpgradeEnabled,
              ),
            ],
          ),

          // ── Privacy ──────────────────────────────────────────────
          SettingsSection(
            title: 'Privacy & Data',
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear browsing data'),
                subtitle: const Text('Cookies, cache, storage, site settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearDataDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.web),
                title: const Text('Site settings'),
                subtitle: Text(
                  '${ref.watch(siteSettingsControllerProvider).length} '
                  'sites with custom settings',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showSiteSettingsList(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showHomePageDialog(
    BuildContext context,
    SettingsController controller,
    BrowserSettings settings,
  ) {
    final textController = TextEditingController(text: settings.homePage);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Default home page'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://google.com',
            prefixIcon: Icon(Icons.link),
          ),
          autocorrect: false,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final value = textController.text.trim();
              await controller.setHomePage(
                value.isEmpty ? 'https://google.com' : value,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showUserAgentDialog(
    BuildContext context,
    SettingsController controller,
    BrowserSettings settings,
  ) {
    final textController = TextEditingController(
      text: settings.customUserAgent,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom user-agent'),
        content: TextField(
          controller: textController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Leave empty to use default user-agent',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await controller.setCustomUserAgent('');
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.setCustomUserAgent(textController.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    var cookies = true;
    var cache = true;
    var storage = true;
    var siteSettings = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Clear browsing data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Cookies'),
                value: cookies,
                onChanged: (v) => setState(() => cookies = v!),
              ),
              CheckboxListTile(
                title: const Text('Cache'),
                value: cache,
                onChanged: (v) => setState(() => cache = v!),
              ),
              CheckboxListTile(
                title: const Text('Local & session storage'),
                value: storage,
                onChanged: (v) => setState(() => storage = v!),
              ),
              CheckboxListTile(
                title: const Text('Site permissions & settings'),
                value: siteSettings,
                onChanged: (v) => setState(() => siteSettings = v!),
              ),
              const SizedBox(height: 8),
              Text(
                'Bookmarks will not be affected.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final options = ClearDataOptions(
                  cookies: cookies,
                  cache: cache,
                  localStorage: storage,
                  siteSettings: siteSettings,
                );
                final service = ClearBrowsingDataService(
                  siteSettingsRepo: ref.read(siteSettingsRepositoryProvider),
                );
                final result = await service.clear(options);

                if (siteSettings) {
                  ref.read(siteSettingsControllerProvider.notifier).clearAll();
                }

                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Cleared ${result.clearedCount} data categories',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSiteSettingsList(BuildContext context, WidgetRef ref) {
    final sites = ref.read(siteSettingsControllerProvider);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Sites with custom settings',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (sites.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(siteSettingsControllerProvider.notifier)
                            .clearAll();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear all'),
                    ),
                ],
              ),
            ),
            if (sites.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No site-specific settings'),
              )
            else
              ...sites.entries.map(
                (e) => ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(e.key),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref
                          .read(siteSettingsControllerProvider.notifier)
                          .removeDomain(e.key);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
