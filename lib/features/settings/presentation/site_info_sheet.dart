import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/url_utils.dart';
import '../domain/site_permission.dart';
import 'site_settings_controller.dart';
import 'widgets/settings_toggle_tile.dart';
import 'widgets/site_permission_tile.dart';

/// Shows per-site info and controls for the currently loaded URL.
class SiteInfoSheet extends ConsumerWidget {
  const SiteInfoSheet({super.key, required this.currentUrl});

  final String currentUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final domain = UrlUtils.extractDomain(currentUrl);
    if (domain == null || domain.isEmpty) {
      return const _EmptySheet(message: 'No site loaded');
    }

    final siteSettings = ref.watch(siteSettingsControllerProvider);
    final site = siteSettings[domain];
    final controller = ref.read(siteSettingsControllerProvider.notifier);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.language, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      domain,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                currentUrl,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),

              // ── Per-site content controls ────────────────────────
              Text(
                'Content settings',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SettingsToggleTile(
                title: 'JavaScript',
                subtitle: site?.javaScriptEnabled == null
                    ? 'Using global default'
                    : null,
                value: site?.javaScriptEnabled ?? true,
                onChanged: (v) => controller.setJavaScript(domain, v),
              ),
              SettingsToggleTile(
                title: 'Block pop-ups',
                subtitle: site?.popUpBlockingEnabled == null
                    ? 'Using global default'
                    : null,
                value: site?.popUpBlockingEnabled ?? true,
                onChanged: (v) => controller.setPopUpBlocking(domain, v),
              ),

              // ── Permissions ──────────────────────────────────────
              const SizedBox(height: 16),
              Text(
                'Permissions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              if (site == null || site.permissions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No permissions requested',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...site.permissions.map(
                  (p) => SitePermissionTile(
                    permission: p,
                    onChanged: (state) =>
                        controller.setPermission(domain, p.type, state),
                  ),
                ),

              // ── Clear site data ──────────────────────────────────
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear site data'),
                subtitle: const Text(
                  'Remove settings & permissions for this site',
                ),
                onTap: () {
                  controller.removeDomain(domain);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cleared data for $domain')),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySheet extends StatelessWidget {
  const _EmptySheet({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(child: Text(message)),
    );
  }
}
