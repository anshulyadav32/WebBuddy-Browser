import 'package:flutter/material.dart';

/// A polished error page shown when a web resource fails to load.
///
/// Displays a friendly message with an optional error description and
/// a retry button. Mirrors the style of typical browser error pages.
class BrowserErrorView extends StatelessWidget {
  const BrowserErrorView({
    super.key,
    required this.url,
    this.errorDescription = '',
    this.errorCode = 0,
    this.onRetry,
  });

  final String url;
  final String errorDescription;
  final int errorCode;
  final VoidCallback? onRetry;

  String get _friendlyTitle {
    if (errorDescription.toLowerCase().contains('net::err_internet_disconnected') ||
        errorDescription.toLowerCase().contains('nsurlerrordomain') ||
        errorCode == -1009) {
      return 'No internet connection';
    }
    if (errorDescription.toLowerCase().contains('net::err_name_not_resolved') ||
        errorCode == -1003) {
      return 'Site not found';
    }
    if (errorDescription.toLowerCase().contains('net::err_connection_timed_out') ||
        errorCode == -1001) {
      return 'Connection timed out';
    }
    if (errorDescription.toLowerCase().contains('net::err_ssl') ||
        errorCode == -1202) {
      return 'Connection is not secure';
    }
    return 'Can\u2019t reach this page';
  }

  String get _friendlySubtitle {
    if (errorDescription.toLowerCase().contains('net::err_internet_disconnected') ||
        errorCode == -1009) {
      return 'Check your Wi-Fi or mobile data and try again.';
    }
    if (errorDescription.toLowerCase().contains('net::err_name_not_resolved') ||
        errorCode == -1003) {
      return 'The web address might be misspelled, or the site may have moved.';
    }
    if (errorDescription.toLowerCase().contains('net::err_connection_timed_out') ||
        errorCode == -1001) {
      return 'The server took too long to respond. Try again later.';
    }
    if (errorDescription.toLowerCase().contains('net::err_ssl') ||
        errorCode == -1202) {
      return 'The certificate for this site is not trusted.';
    }
    return 'Something went wrong loading this page.';
  }

  IconData get _icon {
    if (errorDescription.toLowerCase().contains('net::err_internet_disconnected') ||
        errorCode == -1009) {
      return Icons.wifi_off_rounded;
    }
    if (errorDescription.toLowerCase().contains('net::err_ssl') ||
        errorCode == -1202) {
      return Icons.lock_open_rounded;
    }
    return Icons.cloud_off_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: cs.surface,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 64, color: cs.error.withAlpha(180)),
              const SizedBox(height: 20),
              Text(
                _friendlyTitle,
                style: textTheme.headlineSmall?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _friendlySubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              // Show the URL in a muted style
              Text(
                url,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: cs.outline,
                ),
              ),
              if (errorDescription.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorDescription,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
