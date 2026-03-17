/// Aggregated shield statistics for a single domain or the current session.
class ShieldStats {
  const ShieldStats({
    this.adsBlocked = 0,
    this.trackersBlocked = 0,
    this.totalBlocked = 0,
  });

  /// Number of ad-related requests blocked.
  final int adsBlocked;

  /// Number of tracker-related requests blocked.
  final int trackersBlocked;

  /// Total blocked requests (may exceed ads + trackers if other
  /// categories are added in the future).
  final int totalBlocked;

  ShieldStats copyWith({
    int? adsBlocked,
    int? trackersBlocked,
    int? totalBlocked,
  }) {
    return ShieldStats(
      adsBlocked: adsBlocked ?? this.adsBlocked,
      trackersBlocked: trackersBlocked ?? this.trackersBlocked,
      totalBlocked: totalBlocked ?? this.totalBlocked,
    );
  }

  /// Returns a new [ShieldStats] with one more blocked request added.
  ShieldStats incrementBlocked({bool isTracker = false}) {
    return ShieldStats(
      adsBlocked: isTracker ? adsBlocked : adsBlocked + 1,
      trackersBlocked: isTracker ? trackersBlocked + 1 : trackersBlocked,
      totalBlocked: totalBlocked + 1,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShieldStats &&
          adsBlocked == other.adsBlocked &&
          trackersBlocked == other.trackersBlocked &&
          totalBlocked == other.totalBlocked;

  @override
  int get hashCode => Object.hash(adsBlocked, trackersBlocked, totalBlocked);

  @override
  String toString() =>
      'ShieldStats(ads: $adsBlocked, trackers: $trackersBlocked, total: $totalBlocked)';
}
