import 'package:uuid/uuid.dart';

/// Represents a single browser tab.
class BrowserTab {
  BrowserTab({
    String? id,
    this.url = 'about:blank',
    this.title = 'New Tab',
    this.faviconUrl,
    this.isIncognito = false,
    this.isLoading = false,
    this.canGoBack = false,
    this.canGoForward = false,
    this.loadProgress = 0.0,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final bool isIncognito;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final double loadProgress;
  final DateTime createdAt;

  BrowserTab copyWith({
    String? url,
    String? title,
    String? faviconUrl,
    bool? isIncognito,
    bool? isLoading,
    bool? canGoBack,
    bool? canGoForward,
    double? loadProgress,
  }) {
    return BrowserTab(
      id: id,
      url: url ?? this.url,
      title: title ?? this.title,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      isIncognito: isIncognito ?? this.isIncognito,
      isLoading: isLoading ?? this.isLoading,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      loadProgress: loadProgress ?? this.loadProgress,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BrowserTab && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'BrowserTab(id: $id, title: $title, url: $url)';
}
