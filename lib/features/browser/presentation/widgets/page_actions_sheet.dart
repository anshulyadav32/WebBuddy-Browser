import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/browser_snackbar_helper.dart';

/// A bottom sheet showing contextual actions for the current page.
///
/// Provides: copy URL, find in page, share (copies to clipboard with
/// a snackbar since `share_plus` is not a dependency), and refresh.
///
/// **Long-press link actions**: `webview_flutter` does not provide a
/// reliable API for intercepting long-press / context-menu events on
/// links or images. This feature would require a platform-specific
/// plugin or JavaScript-bridge approach. We therefore provide page-level
/// actions only.
class PageActionsSheet extends StatelessWidget {
  const PageActionsSheet({
    super.key,
    required this.url,
    required this.title,
    this.onFindInPage,
    this.onReload,
    this.onSaveOffline,
    this.onShowSslInfo,
    this.onDeveloperConsole,
    this.onInspectSiteData,
    this.onInspectNetwork,
    this.onOpenOfflinePages,
    this.onOpenDownloads,
    this.onOpenSiteInfo,
    this.onOpenShields,
    this.onOpenSettings,
    this.onSetDefaultHomePage,
    this.onOpenHistory,
    this.longPressTargetUrl,
    this.longPressTargetType,
    this.onOpenLongPressTarget,
    this.onDownloadLongPressTarget,
  });

  final String url;
  final String title;
  final VoidCallback? onFindInPage;
  final VoidCallback? onReload;
  final VoidCallback? onSaveOffline;
  final VoidCallback? onShowSslInfo;
  final VoidCallback? onDeveloperConsole;
  final VoidCallback? onInspectSiteData;
  final VoidCallback? onInspectNetwork;
  final VoidCallback? onOpenOfflinePages;
  final VoidCallback? onOpenDownloads;
  final VoidCallback? onOpenSiteInfo;
  final VoidCallback? onOpenShields;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSetDefaultHomePage;
  final VoidCallback? onOpenHistory;
  final String? longPressTargetUrl;
  final String? longPressTargetType;
  final VoidCallback? onOpenLongPressTarget;
  final VoidCallback? onDownloadLongPressTarget;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withAlpha(80),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Page info header
                Row(
                  children: [
                    Icon(Icons.language, size: 24, color: cs.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'Untitled',
                            style: textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            url,
                            style: textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Scrollable actions
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Actions
                  _ActionTile(
                    icon: Icons.copy_rounded,
                    label: 'Copy link',
                    semanticLabel: 'Copy page URL to clipboard',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: url));
                      Navigator.of(context).pop();
                      BrowserSnackbarHelper.show(
                        context,
                        'Link copied to clipboard',
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.share_rounded,
                    label: 'Share page',
                    semanticLabel: 'Share current page',
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: '$title\n$url'));
                      Navigator.of(context).pop();
                      BrowserSnackbarHelper.show(
                        context,
                        'Page link copied — paste it to share',
                      );
                    },
                  ),
                  if (onFindInPage != null)
                    _ActionTile(
                      icon: Icons.find_in_page_rounded,
                      label: 'Find in page',
                      semanticLabel: 'Search for text on this page',
                      onTap: () {
                        Navigator.of(context).pop();
                        onFindInPage!();
                      },
                    ),
                  if (onReload != null)
                    _ActionTile(
                      icon: Icons.refresh_rounded,
                      label: 'Reload',
                      semanticLabel: 'Reload the current page',
                      onTap: () {
                        Navigator.of(context).pop();
                        onReload!();
                      },
                    ),
                  if (onSaveOffline != null)
                    _ActionTile(
                      icon: Icons.offline_pin_rounded,
                      label: 'Save page offline',
                      onTap: () {
                        Navigator.of(context).pop();
                        onSaveOffline!();
                      },
                    ),
                  if (onShowSslInfo != null)
                    _ActionTile(
                      icon: Icons.verified_user_outlined,
                      label: 'View SSL details',
                      onTap: () {
                        Navigator.of(context).pop();
                        onShowSslInfo!();
                      },
                    ),
                  if (onDeveloperConsole != null)
                    _ActionTile(
                      icon: Icons.terminal,
                      label: 'Developer console',
                      onTap: () {
                        Navigator.of(context).pop();
                        onDeveloperConsole!();
                      },
                    ),
                  if (onInspectSiteData != null)
                    _ActionTile(
                      icon: Icons.storage_rounded,
                      label: 'Inspect cookies & storage',
                      onTap: () {
                        Navigator.of(context).pop();
                        onInspectSiteData!();
                      },
                    ),
                  if (onInspectNetwork != null)
                    _ActionTile(
                      icon: Icons.network_check,
                      label: 'Network info',
                      onTap: () {
                        Navigator.of(context).pop();
                        onInspectNetwork!();
                      },
                    ),
                  if (onOpenOfflinePages != null)
                    _ActionTile(
                      icon: Icons.offline_pin_rounded,
                      label: 'Offline pages',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenOfflinePages!();
                      },
                    ),
                  if (onOpenDownloads != null)
                    _ActionTile(
                      icon: Icons.download,
                      label: 'Downloads',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenDownloads!();
                      },
                    ),
                  if (onOpenSiteInfo != null)
                    _ActionTile(
                      icon: Icons.info_outline,
                      label: 'Site info',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenSiteInfo!();
                      },
                    ),
                  if (onOpenShields != null)
                    _ActionTile(
                      icon: Icons.shield_outlined,
                      label: 'Shields',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenShields!();
                      },
                    ),
                  if (onSetDefaultHomePage != null)
                    _ActionTile(
                      icon: Icons.home_outlined,
                      label: 'Set as default home page',
                      onTap: () {
                        Navigator.of(context).pop();
                        onSetDefaultHomePage!();
                      },
                    ),
                  if (onOpenHistory != null)
                    _ActionTile(
                      icon: Icons.history_rounded,
                      label: 'History',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenHistory!();
                      },
                    ),
                  if (onOpenSettings != null)
                    _ActionTile(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenSettings!();
                      },
                    ),
                  if (longPressTargetUrl != null &&
                      longPressTargetUrl!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.touch_app_outlined),
                      title: Text(
                        'Last long-press target (${longPressTargetType ?? 'link'})',
                      ),
                      subtitle: Text(
                        longPressTargetUrl!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (onOpenLongPressTarget != null)
                    _ActionTile(
                      icon: Icons.open_in_new,
                      label: 'Open long-press target',
                      onTap: () {
                        Navigator.of(context).pop();
                        onOpenLongPressTarget!();
                      },
                    ),
                  if (onDownloadLongPressTarget != null)
                    _ActionTile(
                      icon: Icons.download_for_offline_outlined,
                      label: 'Download long-press target',
                      onTap: () {
                        Navigator.of(context).pop();
                        onDownloadLongPressTarget!();
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: ListTile(leading: Icon(icon), title: Text(label), onTap: onTap),
    );
  }
}
