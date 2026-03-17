/// Per-site shields configuration.
///
/// When [enabled] is `false`, ad/tracker blocking is bypassed for the
/// site — equivalent to Brave's "Shields Down" for that domain.
class SiteShieldSettings {
  const SiteShieldSettings({required this.domain, this.enabled = true});

  /// The domain these settings apply to (e.g. `example.com`).
  final String domain;

  /// Whether shields (ad/tracker blocking) are active for this site.
  final bool enabled;

  SiteShieldSettings copyWith({bool? enabled}) {
    return SiteShieldSettings(domain: domain, enabled: enabled ?? this.enabled);
  }

  Map<String, dynamic> toMap() => {'domain': domain, 'enabled': enabled};

  factory SiteShieldSettings.fromMap(Map<String, dynamic> map) {
    return SiteShieldSettings(
      domain: map['domain'] as String,
      enabled: map['enabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiteShieldSettings && domain == other.domain;

  @override
  int get hashCode => domain.hashCode;

  @override
  String toString() => 'SiteShieldSettings($domain, enabled: $enabled)';
}
