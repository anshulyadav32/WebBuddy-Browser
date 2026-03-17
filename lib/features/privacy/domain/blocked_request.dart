/// A request that was evaluated and blocked by the shields engine.
class BlockedRequest {
  const BlockedRequest({
    required this.url,
    required this.domain,
    required this.matchedFilter,
    required this.blockedAt,
    this.resourceType = ResourceType.other,
    this.isTracker = false,
  });

  /// The full URL of the blocked request.
  final String url;

  /// The domain that was matched against a filter rule.
  final String domain;

  /// The filter rule pattern that caused the block.
  final String matchedFilter;

  /// When the request was blocked.
  final DateTime blockedAt;

  /// The type of resource being requested.
  final ResourceType resourceType;

  /// Whether the request was classified as a tracker (vs. an ad).
  final bool isTracker;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedRequest &&
          url == other.url &&
          blockedAt == other.blockedAt;

  @override
  int get hashCode => Object.hash(url, blockedAt);

  @override
  String toString() => 'BlockedRequest($domain, filter: $matchedFilter)';
}

/// Broad categories for resource types.
///
/// Used for display and heuristic classification. Precise resource-type
/// detection is limited by what `webview_flutter` exposes (see platform
/// limitations in the shields controller).
enum ResourceType {
  script('Script'),
  image('Image'),
  stylesheet('Stylesheet'),
  xmlHttpRequest('XHR'),
  subDocument('Sub-document'),
  other('Other');

  const ResourceType(this.label);
  final String label;
}
