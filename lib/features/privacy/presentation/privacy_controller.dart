import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tabs/application/tabs_controller.dart';
import '../data/private_data_manager.dart';
import '../domain/private_session_state.dart';

// ── Providers ────────────────────────────────────────────────────────

final privateDataManagerProvider = Provider<PrivateDataManager>((ref) {
  return PrivateDataManager();
});

final privacyControllerProvider =
    StateNotifierProvider<PrivacyController, PrivateSessionState>((ref) {
      final dataManager = ref.watch(privateDataManagerProvider);
      final tabsState = ref.watch(tabsControllerProvider);

      final privateTabs = tabsState.tabs.where((t) => t.isPrivate).toList();
      final isActive = privateTabs.isNotEmpty;

      // Return a controller that reflects current private tab state.
      return PrivacyController(
        dataManager: dataManager,
        initialState: PrivateSessionState(
          isActive: isActive,
          privateTabCount: privateTabs.length,
          sessionStartedAt: isActive ? DateTime.now() : null,
        ),
      );
    });

// ── Controller ───────────────────────────────────────────────────────

class PrivacyController extends StateNotifier<PrivateSessionState> {
  PrivacyController({
    required PrivateDataManager dataManager,
    PrivateSessionState initialState = const PrivateSessionState(),
  }) : _dataManager = dataManager,
       super(initialState);

  final PrivateDataManager _dataManager;

  /// Updates the private session state based on current tab count.
  ///
  /// When private tab count drops to zero, triggers session cleanup.
  void updatePrivateTabCount(int count) {
    final wasActive = state.isActive;
    final isNowActive = count > 0;

    state = PrivateSessionState(
      isActive: isNowActive,
      privateTabCount: count,
      sessionStartedAt: isNowActive
          ? (state.sessionStartedAt ?? DateTime.now())
          : null,
    );

    // Session ended — clean up.
    if (wasActive && !isNowActive) {
      _dataManager.clearPrivateSessionData();
    }
  }

  /// Whether history should be recorded for the given privacy flag.
  bool shouldRecordHistory({required bool isPrivate}) {
    return _dataManager.shouldRecordHistory(isPrivate: isPrivate);
  }

  /// Whether tab state should be persisted.
  bool shouldPersistTab({required bool isPrivate}) {
    return _dataManager.shouldPersistTab(isPrivate: isPrivate);
  }

  /// Manually triggers a full private data cleanup.
  Future<void> clearAllPrivateData() async {
    await _dataManager.clearPrivateSessionData();
    state = const PrivateSessionState();
  }
}
