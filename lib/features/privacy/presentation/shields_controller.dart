import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/url_utils.dart';
import '../../settings/presentation/settings_controller.dart';
import '../data/filter_list_repository.dart';
import '../data/request_blocking_engine.dart';
import '../data/shields_repository.dart';
import '../domain/blocked_request.dart';
import '../domain/shield_stats.dart';
import '../domain/site_shield_settings.dart';

// ── Providers ────────────────────────────────────────────────────────

final filterListRepositoryProvider = Provider<FilterListRepository>((ref) {
  return FilterListRepository();
});

final shieldsRepositoryProvider = Provider<ShieldsRepository>((ref) {
  return ShieldsRepository(ref.watch(storageServiceProvider));
});

final shieldsControllerProvider =
    StateNotifierProvider<ShieldsController, ShieldsState>((ref) {
      final shieldsRepo = ref.watch(shieldsRepositoryProvider);
      final filterListRepo = ref.watch(filterListRepositoryProvider);
      final settings = ref.watch(settingsControllerProvider);
      return ShieldsController(
        shieldsRepo: shieldsRepo,
        filterListRepo: filterListRepo,
        globalAdBlockEnabled: settings.adBlockEnabled,
      );
    });

// ── State ────────────────────────────────────────────────────────────

/// Complete shields state visible to the UI.
class ShieldsState {
  const ShieldsState({
    this.isInitialised = false,
    this.globalEnabled = true,
    this.currentDomain,
    this.currentSiteEnabled = true,
    this.stats = const ShieldStats(),
    this.blockedRequests = const [],
    this.siteOverrides = const {},
  });

  /// Whether the blocking engine has loaded filter rules.
  final bool isInitialised;

  /// Whether ad-blocking is globally enabled in settings.
  final bool globalEnabled;

  /// The domain of the currently loaded page (for per-site controls).
  final String? currentDomain;

  /// Whether shields are enabled for the current site.
  final bool currentSiteEnabled;

  /// Aggregated stats for the current page load.
  final ShieldStats stats;

  /// Log of blocked requests for the current page.
  final List<BlockedRequest> blockedRequests;

  /// All per-site shield overrides.
  final Map<String, SiteShieldSettings> siteOverrides;

  /// Whether blocking is effectively active for the current page.
  bool get isEffectivelyEnabled =>
      globalEnabled && currentSiteEnabled && isInitialised;

  ShieldsState copyWith({
    bool? isInitialised,
    bool? globalEnabled,
    String? Function()? currentDomain,
    bool? currentSiteEnabled,
    ShieldStats? stats,
    List<BlockedRequest>? blockedRequests,
    Map<String, SiteShieldSettings>? siteOverrides,
  }) {
    return ShieldsState(
      isInitialised: isInitialised ?? this.isInitialised,
      globalEnabled: globalEnabled ?? this.globalEnabled,
      currentDomain: currentDomain != null
          ? currentDomain()
          : this.currentDomain,
      currentSiteEnabled: currentSiteEnabled ?? this.currentSiteEnabled,
      stats: stats ?? this.stats,
      blockedRequests: blockedRequests ?? this.blockedRequests,
      siteOverrides: siteOverrides ?? this.siteOverrides,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShieldsState &&
          isInitialised == other.isInitialised &&
          globalEnabled == other.globalEnabled &&
          currentDomain == other.currentDomain &&
          currentSiteEnabled == other.currentSiteEnabled &&
          stats == other.stats &&
          blockedRequests.length == other.blockedRequests.length;

  @override
  int get hashCode => Object.hash(
    isInitialised,
    globalEnabled,
    currentDomain,
    currentSiteEnabled,
    stats,
    blockedRequests.length,
  );
}

// ── Controller ───────────────────────────────────────────────────────

/// Manages the shields/ad-blocking lifecycle.
///
/// ## Platform limitations
///
/// Flutter's `webview_flutter` plugin does **not** expose a network-level
/// request interception API comparable to Chrome's `webRequest` or
/// WKWebView's `WKContentRuleListStore`. This means:
///
/// - **Navigation requests** can be intercepted via `NavigationDelegate.
///   onNavigationRequest` — we use this to block top-level and sub-frame
///   navigations to known ad/tracker domains.
/// - **Sub-resource requests** (scripts, images, XHR) **cannot** be
///   individually intercepted. To mitigate this, we inject JavaScript
///   that hides cosmetic ad elements and attempts to block known
///   tracker scripts via DOM manipulation.
/// - Full request-level blocking (like uBlock Origin / Brave Shields)
///   requires platform-specific WebView extensions that are outside
///   the `webview_flutter` plugin's scope.
///
/// This implementation is therefore a **best-effort MVP** that:
/// 1. Blocks navigation-level requests to ad/tracker domains.
/// 2. Injects CSS to hide cosmetic ad elements.
/// 3. Logs what *would* have been blocked for display in the shields panel.
class ShieldsController extends StateNotifier<ShieldsState> {
  ShieldsController({
    required this.shieldsRepo,
    required this.filterListRepo,
    required bool globalAdBlockEnabled,
  }) : super(
         ShieldsState(globalEnabled: globalAdBlockEnabled, siteOverrides: {}),
       ) {
    _init();
  }

  final ShieldsRepository shieldsRepo;
  final FilterListRepository filterListRepo;

  RequestBlockingEngine? _engine;

  /// Initialises the blocking engine by loading filter rules.
  Future<void> _init() async {
    final overrides = shieldsRepo.loadAll();
    final rules = await filterListRepo.loadRules();
    _engine = RequestBlockingEngine(rules: rules);
    state = state.copyWith(isInitialised: true, siteOverrides: overrides);
  }

  /// Access the blocking engine (may be null before init completes).
  RequestBlockingEngine? get engine => _engine;

  /// Updates the current page domain (called on navigation events).
  void setCurrentPage(String url) {
    final domain = UrlUtils.extractDomain(url);
    final siteEnabled = domain != null
        ? (state.siteOverrides[domain]?.enabled ?? true)
        : true;
    state = state.copyWith(
      currentDomain: () => domain,
      currentSiteEnabled: siteEnabled,
      // Reset stats for the new page.
      stats: const ShieldStats(),
      blockedRequests: [],
    );
  }

  /// Evaluates a request URL and returns whether it should be blocked.
  ///
  /// Also records the blocked request in state for display.
  BlockDecision evaluateRequest({
    required String requestUrl,
    required String pageUrl,
  }) {
    if (!state.isEffectivelyEnabled || _engine == null) {
      return BlockDecision.allowed;
    }

    final decision = _engine!.evaluate(
      requestUrl: requestUrl,
      pageUrl: pageUrl,
    );

    if (decision.shouldBlock) {
      final blocked = RequestBlockingEngine.toBlockedRequest(
        decision,
        requestUrl,
      );
      state = state.copyWith(
        stats: state.stats.incrementBlocked(isTracker: decision.isTracker),
        blockedRequests: [...state.blockedRequests, blocked],
      );
    }

    return decision;
  }

  /// Toggles shields for the current site.
  ///
  /// Returns `true` if the caller should reload the page.
  Future<bool> toggleCurrentSiteShield() async {
    final domain = state.currentDomain;
    if (domain == null) return false;

    final newEnabled = !state.currentSiteEnabled;
    final settings = SiteShieldSettings(domain: domain, enabled: newEnabled);
    await shieldsRepo.save(settings);

    state = state.copyWith(
      currentSiteEnabled: newEnabled,
      siteOverrides: {...state.siteOverrides, domain: settings},
      // Reset stats when toggling.
      stats: const ShieldStats(),
      blockedRequests: [],
    );

    return true; // Caller should reload.
  }

  /// Toggles shields for a specific domain.
  Future<void> toggleSiteShield(String domain, bool enabled) async {
    final settings = SiteShieldSettings(domain: domain, enabled: enabled);
    await shieldsRepo.save(settings);

    final overrides = {...state.siteOverrides, domain: settings};
    final isCurrent = domain == state.currentDomain;

    state = state.copyWith(
      siteOverrides: overrides,
      currentSiteEnabled: isCurrent ? enabled : null,
    );
  }

  /// Returns cosmetic selectors for the given page URL.
  List<String> getCosmeticSelectors(String pageUrl) {
    if (!state.isEffectivelyEnabled || _engine == null) return [];
    return _engine!.cosmeticSelectorsFor(pageUrl);
  }

  /// Builds JavaScript to inject for cosmetic element hiding.
  String? buildCosmeticInjectionScript(String pageUrl) {
    final selectors = getCosmeticSelectors(pageUrl);
    if (selectors.isEmpty) return null;

    // Build a CSS rule that hides all matched selectors.
    final cssSelectors = selectors
        .map((s) => s.replaceAll("'", "\\'"))
        .join(', ');
    return '''
      (function() {
        var style = document.createElement('style');
        style.textContent = '$cssSelectors { display: none !important; }';
        (document.head || document.documentElement).appendChild(style);
      })();
    ''';
  }
}
