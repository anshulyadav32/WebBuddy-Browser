import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:web_buddy/features/privacy/domain/entities/site_shields.dart';
import 'package:web_buddy/features/privacy/domain/services/filter_engine.dart';
import 'package:web_buddy/features/settings/presentation/providers/settings_provider.dart';

final _log = Logger('PrivacyProvider');

/// Global filter engine instance.
final filterEngineProvider = Provider<FilterEngine>((ref) {
  return FilterEngine();
});

/// Provider to initialize filter lists on app start.
final filterListInitProvider = FutureProvider<void>((ref) async {
  final engine = ref.read(filterEngineProvider);

  try {
    // Load built-in basic filter list from assets
    final content =
        await rootBundle.loadString('assets/filter_lists/basic_filters.txt');
    engine.loadRules(content);
    _log.info('Filter engine initialized with ${engine.totalRuleCount} rules');
  } catch (e) {
    _log.warning('Failed to load filter lists: $e');
    // App continues without filters — this is non-fatal
  }
});

/// Per-site shields state, keyed by host.
final siteShieldsProvider =
    NotifierProvider.family<SiteShieldsNotifier, SiteShields, String>(
  SiteShieldsNotifier.new,
);

class SiteShieldsNotifier extends FamilyNotifier<SiteShields, String> {
  @override
  SiteShields build(String arg) {
    final settings = ref.watch(settingsProvider);
    return SiteShields(
      host: arg,
      adsBlocked: settings.adBlockingEnabled,
      trackersBlocked: settings.trackerBlockingEnabled,
      httpsUpgraded: settings.httpsUpgradeEnabled,
      javascriptEnabled: settings.javascriptEnabled,
      fingerprintingBlocked: settings.antiFingerprinting,
    );
  }

  void toggleAds() {
    state = state.copyWith(adsBlocked: !state.adsBlocked);
  }

  void toggleTrackers() {
    state = state.copyWith(trackersBlocked: !state.trackersBlocked);
  }

  void toggleHttpsUpgrade() {
    state = state.copyWith(httpsUpgraded: !state.httpsUpgraded);
  }

  void toggleJavascript() {
    state = state.copyWith(javascriptEnabled: !state.javascriptEnabled);
  }

  void toggleFingerprinting() {
    state = state.copyWith(
        fingerprintingBlocked: !state.fingerprintingBlocked);
  }

  void disableAllShields() {
    state = SiteShields(
      host: arg,
      adsBlocked: false,
      trackersBlocked: false,
      httpsUpgraded: false,
      fingerprintingBlocked: false,
    );
  }

  void enableAllShields() {
    state = SiteShields(
      host: arg,
      adsBlocked: true,
      trackersBlocked: true,
      httpsUpgraded: true,
      fingerprintingBlocked: true,
    );
  }
}

/// Tracks blocked request counts per tab.
final blockedCountProvider =
    StateProvider.family<int, String>((ref, tabId) => 0);

/// Tracks blocked URLs per tab for the shields panel.
final blockedUrlsProvider =
    StateProvider.family<List<BlockedRequestInfo>, String>(
  (ref, tabId) => [],
);

/// Information about a blocked request.
class BlockedRequestInfo {
  final String url;
  final String? matchedRule;
  final DateTime blockedAt;

  const BlockedRequestInfo({
    required this.url,
    this.matchedRule,
    required this.blockedAt,
  });
}
