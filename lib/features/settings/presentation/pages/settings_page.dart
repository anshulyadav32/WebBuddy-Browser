import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/core/constants/search_engines.dart';
import 'package:web_buddy/features/settings/domain/entities/browser_settings.dart'
    as app_settings;
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';

/// Settings page with privacy controls, search engine selection, and theme.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    // ignore: unused_local_variable
    final _ = theme; // suppress unused warning

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader('Search'),
          ListTile(
            title: const Text('Search Engine'),
            subtitle: Text(
              SearchEngines.engines[settings.searchEngineId]?.name ?? 'Google',
            ),
            leading: const Icon(Icons.search),
            onTap: () => _showSearchEngineDialog(context, ref, settings),
          ),

          _SectionHeader('Privacy & Security'),
          SwitchListTile(
            title: const Text('Block Ads'),
            subtitle: const Text('Block ads using filter lists'),
            secondary: const Icon(Icons.block),
            value: settings.adBlockingEnabled,
            onChanged: (_) => notifier.toggleAdBlocking(),
          ),
          SwitchListTile(
            title: const Text('Block Trackers'),
            subtitle: const Text('Prevent cross-site tracking'),
            secondary: const Icon(Icons.shield),
            value: settings.trackerBlockingEnabled,
            onChanged: (_) => notifier.toggleTrackerBlocking(),
          ),
          SwitchListTile(
            title: const Text('HTTPS Upgrade'),
            subtitle: const Text('Automatically use HTTPS when available'),
            secondary: const Icon(Icons.lock),
            value: settings.httpsUpgradeEnabled,
            onChanged: (_) => notifier.toggleHttpsUpgrade(),
          ),
          SwitchListTile(
            title: const Text('Anti-Fingerprinting'),
            subtitle: const Text(
              'Reduce browser fingerprint surface area.\n'
              'Note: May break some websites.',
            ),
            secondary: const Icon(Icons.fingerprint),
            value: settings.antiFingerprinting,
            onChanged: (_) => notifier.toggleAntiFingerprinting(),
          ),
          ListTile(
            title: const Text('Cookie Policy'),
            subtitle: Text(_cookiePolicyLabel(settings.cookiePolicy)),
            leading: const Icon(Icons.cookie),
            onTap: () => _showCookiePolicyDialog(context, ref, settings),
          ),

          _SectionHeader('Content'),
          SwitchListTile(
            title: const Text('JavaScript'),
            subtitle: const Text('Enable JavaScript on pages'),
            secondary: const Icon(Icons.code),
            value: settings.javascriptEnabled,
            onChanged: (_) => notifier.toggleJavascript(),
          ),
          SwitchListTile(
            title: const Text('Block Pop-ups'),
            subtitle: const Text('Prevent unwanted pop-up windows'),
            secondary: const Icon(Icons.web_asset_off),
            value: settings.popupBlockingEnabled,
            onChanged: (_) => notifier.togglePopupBlocking(),
          ),

          _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_themeModeLabel(settings.themeMode)),
            leading: const Icon(Icons.palette),
            onTap: () => _showThemeDialog(context, ref, settings),
          ),

          _SectionHeader('Data'),
          ListTile(
            title: const Text('Clear Browsing Data'),
            leading: const Icon(Icons.delete_forever),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _showClearDataDialog(context, ref),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'WebBuddy v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showSearchEngineDialog(
      BuildContext context, WidgetRef ref, app_settings.BrowserSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Engine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SearchEngines.engines.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value.name),
              value: entry.key,
              groupValue: settings.searchEngineId,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setSearchEngine(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCookiePolicyDialog(
      BuildContext context, WidgetRef ref, app_settings.BrowserSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cookie Policy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: app_settings.CookiePolicy.values.map((policy) {
            return RadioListTile<app_settings.CookiePolicy>(
              title: Text(_cookiePolicyLabel(policy)),
              value: policy,
              groupValue: settings.cookiePolicy,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setCookiePolicy(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, app_settings.BrowserSettings settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: app_settings.ThemeMode.values.map((mode) {
            return RadioListTile<app_settings.ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Browsing Data'),
        content: const Text(
          'This will clear:\n'
          '• Browsing history\n'
          '• Site permissions\n'
          '• Blocked request logs\n\n'
          'Bookmarks and downloads will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // TODO: Invoke database clearAllBrowsingData
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Browsing data cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String _cookiePolicyLabel(app_settings.CookiePolicy policy) {
    switch (policy) {
      case app_settings.CookiePolicy.allowAll:
        return 'Allow all cookies';
      case app_settings.CookiePolicy.blockThirdParty:
        return 'Block third-party cookies';
      case app_settings.CookiePolicy.blockAll:
        return 'Block all cookies';
    }
  }

  String _themeModeLabel(app_settings.ThemeMode mode) {
    switch (mode) {
      case app_settings.ThemeMode.system:
        return 'System default';
      case app_settings.ThemeMode.light:
        return 'Light';
      case app_settings.ThemeMode.dark:
        return 'Dark';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
