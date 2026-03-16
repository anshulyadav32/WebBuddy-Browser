import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/features/downloads/presentation/providers/download_provider.dart';

/// Page displaying all downloads with their status.
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
      ),
      body: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error loading downloads: $error'),
        ),
        data: (downloads) {
          if (downloads.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.download,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: downloads.length,
            itemBuilder: (context, index) {
              final download = downloads[index];
              return ListTile(
                leading: Icon(
                  _statusIcon(download.status),
                  color: _statusColor(download.status),
                ),
                title: Text(
                  download.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      download.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    if (download.status == DownloadStatus.downloading)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: LinearProgressIndicator(
                          value: download.fileSize > 0
                              ? download.downloadedBytes / download.fileSize
                              : null,
                        ),
                      ),
                    Text(
                      _statusText(download.status),
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusColor(download.status),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        ref
                            .read(downloadActionsProvider)
                            .removeDownload(download.id);
                        ref.invalidate(downloadListProvider);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'delete', child: Text('Remove')),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case DownloadStatus.pending:
        return Icons.hourglass_empty;
      case DownloadStatus.downloading:
        return Icons.downloading;
      case DownloadStatus.completed:
        return Icons.download_done;
      case DownloadStatus.failed:
        return Icons.error_outline;
      case DownloadStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.cancelled:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _statusText(int status) {
    switch (status) {
      case DownloadStatus.pending:
        return 'Pending';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.completed:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
