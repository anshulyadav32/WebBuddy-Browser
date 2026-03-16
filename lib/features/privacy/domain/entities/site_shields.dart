/// Per-site shields configuration.
class SiteShields {
  final String host;
  final bool adsBlocked;
  final bool trackersBlocked;
  final bool httpsUpgraded;
  final bool javascriptEnabled;
  final bool fingerprintingBlocked;

  const SiteShields({
    required this.host,
    this.adsBlocked = true,
    this.trackersBlocked = true,
    this.httpsUpgraded = true,
    this.javascriptEnabled = true,
    this.fingerprintingBlocked = false,
  });

  SiteShields copyWith({
    bool? adsBlocked,
    bool? trackersBlocked,
    bool? httpsUpgraded,
    bool? javascriptEnabled,
    bool? fingerprintingBlocked,
  }) {
    return SiteShields(
      host: host,
      adsBlocked: adsBlocked ?? this.adsBlocked,
      trackersBlocked: trackersBlocked ?? this.trackersBlocked,
      httpsUpgraded: httpsUpgraded ?? this.httpsUpgraded,
      javascriptEnabled: javascriptEnabled ?? this.javascriptEnabled,
      fingerprintingBlocked:
          fingerprintingBlocked ?? this.fingerprintingBlocked,
    );
  }

  /// Whether any shield is active.
  bool get isAnyShieldActive =>
      adsBlocked || trackersBlocked || httpsUpgraded || fingerprintingBlocked;
}
