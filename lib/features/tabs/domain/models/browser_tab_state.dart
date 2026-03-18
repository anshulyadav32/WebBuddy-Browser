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
    this.groupId,
  });

  /// Creates a new tab with a generated UUID and homepage.
  factory BrowserTabState.create({
    bool isPrivate = false,
    String homepage = 'about:blank',
    String? groupId,
  }) {
    return BrowserTabState(
      id: const Uuid().v4(),
      currentUrl: homepage,
      title: 'New Tab',
      isPrivate: isPrivate,
      groupId: groupId,
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
  final String? groupId;

  BrowserTabState copyWith({
    String? currentUrl,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? isPrivate,
    String? groupId,
    bool clearGroup = false,
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
      groupId: clearGroup ? null : (groupId ?? this.groupId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowserTabState &&
          id == other.id &&
          currentUrl == other.currentUrl &&
          title == other.title &&
          isLoading == other.isLoading &&
          progress == other.progress &&
          canGoBack == other.canGoBack &&
          canGoForward == other.canGoForward &&
          isPrivate == other.isPrivate &&
          groupId == other.groupId;

  @override
  int get hashCode => Object.hash(
    id,
    currentUrl,
    title,
    isLoading,
    progress,
    canGoBack,
    canGoForward,
    isPrivate,
    groupId,
  );

  @override
  String toString() =>
      'BrowserTabState(id: $id, title: $title, url: $currentUrl)';
}
