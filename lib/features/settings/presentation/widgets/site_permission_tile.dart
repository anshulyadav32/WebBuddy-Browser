import 'package:flutter/material.dart';

import '../../domain/site_permission.dart';

/// Displays a single site permission with its current state and a toggle.
class SitePermissionTile extends StatelessWidget {
  const SitePermissionTile({
    super.key,
    required this.permission,
    required this.onChanged,
  });

  final SitePermission permission;
  final ValueChanged<PermissionState> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_iconFor(permission.type)),
      title: Text(permission.type.label),
      subtitle: Text(permission.state.label),
      trailing: PopupMenuButton<PermissionState>(
        onSelected: onChanged,
        itemBuilder: (_) => PermissionState.values
            .map((ps) => PopupMenuItem(value: ps, child: Text(ps.label)))
            .toList(),
      ),
    );
  }

  IconData _iconFor(SitePermissionType type) {
    return switch (type) {
      SitePermissionType.camera => Icons.videocam,
      SitePermissionType.microphone => Icons.mic,
      SitePermissionType.location => Icons.location_on,
      SitePermissionType.notifications => Icons.notifications,
    };
  }
}
