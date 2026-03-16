/// Tracks the state of the current private browsing session.
class PrivateSessionState {
  const PrivateSessionState({
    this.isActive = false,
    this.privateTabCount = 0,
    this.sessionStartedAt,
  });

  /// Whether any private tabs are currently open.
  final bool isActive;

  /// Number of open private tabs.
  final int privateTabCount;

  /// When the current private session started (first private tab opened).
  final DateTime? sessionStartedAt;

  PrivateSessionState copyWith({
    bool? isActive,
    int? privateTabCount,
    DateTime? sessionStartedAt,
  }) {
    return PrivateSessionState(
      isActive: isActive ?? this.isActive,
      privateTabCount: privateTabCount ?? this.privateTabCount,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateSessionState &&
          isActive == other.isActive &&
          privateTabCount == other.privateTabCount;

  @override
  int get hashCode => Object.hash(isActive, privateTabCount);

  @override
  String toString() =>
      'PrivateSessionState(active: $isActive, tabs: $privateTabCount)';
}
