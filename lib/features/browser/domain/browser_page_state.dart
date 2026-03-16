/// Immutable state for the single-tab browser view.
class BrowserPageState {
  const BrowserPageState({
    this.currentUrl = 'https://flutter.dev',
    this.title = '',
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
  });

  final String currentUrl;
  final String title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;

  BrowserPageState copyWith({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
  }) {
    return BrowserPageState(
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserPageState &&
          currentUrl == other.currentUrl &&
          title == other.title &&
          isLoading == other.isLoading &&
          progress == other.progress &&
          canGoBack == other.canGoBack &&
          canGoForward == other.canGoForward;

  @override
  int get hashCode => Object.hash(
        currentUrl,
        title,
        isLoading,
        progress,
        canGoBack,
        canGoForward,
      );

  @override
  String toString() =>
      'BrowserPageState(url: $currentUrl, title: $title, loading: $isLoading)';
}
