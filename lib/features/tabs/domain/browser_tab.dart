import 'package:uuid/uuid.dart';

/// Represents a single browser tab.
class BrowserTab {
  final String id;
  final String url;
  final String title;
  final String? favicon;
  final bool isIncognito;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final double loadProgress;
  final int blockedRequestCount;
  final DateTime createdAt;
  final bool isActive;
  final String? errorMessage;

  const BrowserTab({
    required this.id,
    this.url = 'about:blank',
    this.title = 'New Tab',
    this.favicon,
    this.isIncognito = false,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.loadProgress = 0.0,
    this.blockedRequestCount = 0,
    required this.createdAt,
    this.isActive = false,
    this.errorMessage,
  });

  factory BrowserTab.create({bool isIncognito = false, String? initialUrl}) {
    return BrowserTab(
      id: const Uuid().v4(),
      url: initialUrl ?? 'about:blank',
      isIncognito: isIncognito,
      createdAt: DateTime.now(),
    );
  }

  BrowserTab copyWith({
    String? url,
    String? title,
    String? favicon,
    bool? isLoading,
    bool? canGoBack,
    bool? canGoForward,
    double? loadProgress,
    int? blockedRequestCount,
    bool? isActive,
    String? errorMessage,
  }) {
    return BrowserTab(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      favicon: favicon ?? this.favicon,
      isIncognito: isIncognito,
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      loadProgress: loadProgress ?? this.loadProgress,
      blockedRequestCount: blockedRequestCount ?? this.blockedRequestCount,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      errorMessage: errorMessage,
    );
  }

  bool get isNewTab => url == 'about:blank';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrowserTab && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
