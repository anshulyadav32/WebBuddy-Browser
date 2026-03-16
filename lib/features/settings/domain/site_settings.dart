import 'site_permission.dart';

/// Per-site settings bundle.
///
/// Stores content overrides and permission decisions for a single domain.
class SiteSettings {
  const SiteSettings({
    required this.domain,
    this.javaScriptEnabled,
    this.popUpBlockingEnabled,
    this.permissions = const [],
  });

  /// The domain these settings apply to (e.g. `example.com`).
  final String domain;

  /// Per-site JavaScript override. `null` → use global default.
  final bool? javaScriptEnabled;

  /// Per-site pop-up blocking override. `null` → use global default.
  final bool? popUpBlockingEnabled;

  /// Recorded permission decisions for this site.
  final List<SitePermission> permissions;

  SiteSettings copyWith({
    bool? Function()? javaScriptEnabled,
    bool? Function()? popUpBlockingEnabled,
    List<SitePermission>? permissions,
  }) {
    return SiteSettings(
      domain: domain,
      javaScriptEnabled: javaScriptEnabled != null
          ? javaScriptEnabled()
          : this.javaScriptEnabled,
      popUpBlockingEnabled: popUpBlockingEnabled != null
          ? popUpBlockingEnabled()
          : this.popUpBlockingEnabled,
      permissions: permissions ?? this.permissions,
    );
  }

  /// Serialize for JSON persistence.
  Map<String, dynamic> toMap() => {
    'domain': domain,
    'javaScriptEnabled': javaScriptEnabled,
    'popUpBlockingEnabled': popUpBlockingEnabled,
    'permissions': permissions.map((p) => p.toMap()).toList(),
  };

  factory SiteSettings.fromMap(Map<String, dynamic> map) {
    return SiteSettings(
      domain: map['domain'] as String,
      javaScriptEnabled: map['javaScriptEnabled'] as bool?,
      popUpBlockingEnabled: map['popUpBlockingEnabled'] as bool?,
      permissions:
          (map['permissions'] as List<dynamic>?)
              ?.map((e) => SitePermission.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SiteSettings && domain == other.domain;

  @override
  int get hashCode => domain.hashCode;

  @override
  String toString() => 'SiteSettings($domain)';
}
