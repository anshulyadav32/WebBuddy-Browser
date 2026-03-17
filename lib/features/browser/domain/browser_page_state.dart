/// Immutable state for the single-tab browser view.
class BrowserPageState {
  const BrowserPageState({
    this.currentUrl = 'https://flutter.dev',
    this.title = '',
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.hasError = false,
    this.errorDescription = '',
    this.errorCode = 0,
  });

  final String currentUrl;
  final String title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final bool hasError;
  final String errorDescription;
  final int errorCode;

  BrowserPageState copyWith({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? hasError,
    String? errorDescription,
    int? errorCode,
  }) {
    return BrowserPageState(
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      hasError: hasError ?? this.hasError,
      errorDescription: errorDescription ?? this.errorDescription,
      errorCode: errorCode ?? this.errorCode,
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
          canGoForward == other.canGoForward &&
          hasError == other.hasError &&
          errorDescription == other.errorDescription &&
          errorCode == other.errorCode;

  @override
  int get hashCode => Object.hash(
    currentUrl,
    title,
    isLoading,
    progress,
    canGoBack,
    canGoForward,
    hasError,
    errorDescription,
    errorCode,
  );

  @override
  String toString() =>
      'BrowserPageState(url: $currentUrl, title: $title, loading: $isLoading, error: $hasError)';
}
