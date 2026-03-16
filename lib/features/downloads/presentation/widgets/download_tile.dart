import 'package:flutter/material.dart';

import '../../domain/download_item.dart';
import '../../domain/file_name_utils.dart';

/// A single row in the downloads list.
class DownloadTile extends StatelessWidget {
  const DownloadTile({
    super.key,
    required this.item,
    this.onOpen,
    this.onCancel,
    this.onDelete,
  });

  final DownloadItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: _statusIcon(cs),
      title: Text(
        item.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyMedium,
      ),
      subtitle: _subtitle(cs, textTheme),
      trailing: _trailingAction(cs),
    );
  }

  Widget _statusIcon(ColorScheme cs) {
    switch (item.status) {
      case DownloadStatus.queued:
        return Icon(Icons.hourglass_top, color: cs.secondary);
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: item.progress > 0 ? item.progress : null,
            strokeWidth: 2.5,
          ),
        );
      case DownloadStatus.completed:
        return Icon(Icons.check_circle, color: cs.primary);
      case DownloadStatus.failed:
        return Icon(Icons.error, color: cs.error);
      case DownloadStatus.cancelled:
        return Icon(Icons.cancel, color: cs.outline);
    }
  }

  Widget? _subtitle(ColorScheme cs, TextTheme textTheme) {
    switch (item.status) {
      case DownloadStatus.downloading:
        final received = FileNameUtils.formatBytes(item.receivedBytes);
        final total = item.totalBytes > 0
            ? FileNameUtils.formatBytes(item.totalBytes)
            : '?';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: item.progress > 0 ? item.progress : null,
              minHeight: 3,
            ),
            const SizedBox(height: 2),
            Text(
              '$received / $total',
              style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        );
      case DownloadStatus.completed:
        return Text(
          item.totalBytes > 0
              ? FileNameUtils.formatBytes(item.totalBytes)
              : 'Completed',
          style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        );
      case DownloadStatus.failed:
        return Text(
          'Download failed',
          style: textTheme.bodySmall?.copyWith(color: cs.error),
        );
      case DownloadStatus.cancelled:
        return Text(
          'Cancelled',
          style: textTheme.bodySmall?.copyWith(color: cs.outline),
        );
      case DownloadStatus.queued:
        return Text(
          'Waiting…',
          style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        );
    }
  }

  Widget? _trailingAction(ColorScheme cs) {
    switch (item.status) {
      case DownloadStatus.downloading:
        return IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: onCancel,
        );
      case DownloadStatus.completed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onOpen != null)
              IconButton(
                icon: Icon(Icons.open_in_new, color: cs.primary),
                tooltip: 'Open',
                onPressed: onOpen,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
              onPressed: onDelete,
            ),
          ],
        );
      default:
        return IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove',
          onPressed: onDelete,
        );
    }
  }
}
