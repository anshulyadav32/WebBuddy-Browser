/// Types of permissions that can be granted per-site.
///
/// ## Platform limitations
///
/// Flutter's `webview_flutter` plugin surfaces permission requests only on
/// Android (via `onPermissionRequest` in the platform WebView). On
/// macOS/iOS the WKWebView permission model is handled by the OS and is
/// **not** exposed through the plugin's API. The values stored here are
/// therefore used to *record* grant/deny decisions and display them in the
/// UI, but only take practical effect on platforms where the underlying
/// WebView supports programmatic permission control.
enum SitePermissionType {
  camera('Camera'),
  microphone('Microphone'),
  location('Location'),
  notifications('Notifications');

  const SitePermissionType(this.label);
  final String label;
}

/// The grant state for a permission.
enum PermissionState {
  ask('Ask every time'),
  allow('Allow'),
  deny('Deny');

  const PermissionState(this.label);
  final String label;
}

/// A recorded permission decision for one permission on one site.
class SitePermission {
  const SitePermission({
    required this.domain,
    required this.type,
    this.state = PermissionState.ask,
  });

  final String domain;
  final SitePermissionType type;
  final PermissionState state;

  SitePermission copyWith({PermissionState? state}) {
    return SitePermission(
      domain: domain,
      type: type,
      state: state ?? this.state,
    );
  }

  /// Serialize to a flat map for JSON storage.
  Map<String, dynamic> toMap() => {
    'domain': domain,
    'type': type.index,
    'state': state.index,
  };

  factory SitePermission.fromMap(Map<String, dynamic> map) {
    return SitePermission(
      domain: map['domain'] as String,
      type: SitePermissionType.values[map['type'] as int],
      state: PermissionState.values[map['state'] as int? ?? 0],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SitePermission && domain == other.domain && type == other.type;

  @override
  int get hashCode => Object.hash(domain, type);

  @override
  String toString() => 'SitePermission($domain, ${type.label}: ${state.label})';
}
