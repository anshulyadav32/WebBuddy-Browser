import 'package:uuid/uuid.dart';

/// Immutable state for a single browser tab.
class BrowserTabState {
  const BrowserTabState({
    required this.id,
    this.currentUrl = 'about:blank',
    this.title = 'New Tab',
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isPrivate = false,
  });

  /// Creates a new tab with a generated UUID.
  factory BrowserTabState.create({bool isPrivate = false}) {
    return BrowserTabState(
      id: const Uuid().v4(),
      isPrivate: isPrivate,
    );
  }

  final String id;
  final String currentUrl;
  final String title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final bool isPrivate;

  BrowserTabState copyWith({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? isPrivate,
  }) {
    return BrowserTabState(
      id: id,
      currentUrl: currentUrl ?? this.currentUrl,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrowserTabState && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'BrowserTabState(id: $id, title: $title, url: $currentUrl)';
}
