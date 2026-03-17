import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/blocked_request.dart';

/// A single row displaying a blocked request in the shields panel log.
class BlockedRequestTile extends StatelessWidget {
  const BlockedRequestTile({super.key, required this.request});

  final BlockedRequest request;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            request.isTracker ? Icons.visibility_off : Icons.block,
            size: 16,
            color: request.isTracker ? cs.tertiary : cs.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.domain,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  request.matchedFilter,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat.Hms().format(request.blockedAt),
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
