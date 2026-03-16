import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';
import 'package:web_buddy/features/privacy/domain/private_session_state.dart';
import 'package:web_buddy/features/privacy/presentation/privacy_controller.dart';

/// A fake data manager that tracks cleanup calls.
class FakePrivateDataManager extends PrivateDataManager {
  int clearCallCount = 0;

  @override
  Future<void> clearPrivateSessionData({dynamic webViewController}) async {
    clearCallCount++;
  }
}

void main() {
  group('PrivacyController', () {
    late FakePrivateDataManager fakeManager;
    late PrivacyController controller;

    setUp(() {
      fakeManager = FakePrivateDataManager();
      controller = PrivacyController(dataManager: fakeManager);
    });

    test('initial state is inactive', () {
      expect(controller.state.isActive, isFalse);
      expect(controller.state.privateTabCount, 0);
      expect(controller.state.sessionStartedAt, isNull);
    });

    test('updatePrivateTabCount activates session', () {
      controller.updatePrivateTabCount(2);

      expect(controller.state.isActive, isTrue);
      expect(controller.state.privateTabCount, 2);
      expect(controller.state.sessionStartedAt, isNotNull);
    });

    test('updatePrivateTabCount to zero deactivates and cleans up', () {
      controller.updatePrivateTabCount(1);
      controller.updatePrivateTabCount(0);

      expect(controller.state.isActive, isFalse);
      expect(controller.state.privateTabCount, 0);
      expect(controller.state.sessionStartedAt, isNull);
      expect(fakeManager.clearCallCount, 1);
    });

    test('cleanup only triggers on transition from active to inactive', () {
      // Already inactive, setting to 0 again should not trigger cleanup.
      controller.updatePrivateTabCount(0);
      expect(fakeManager.clearCallCount, 0);
    });

    test('session start time preserved across count changes', () {
      controller.updatePrivateTabCount(1);
      final startTime = controller.state.sessionStartedAt;

      controller.updatePrivateTabCount(3);
      expect(controller.state.sessionStartedAt, startTime);
    });

    test('shouldRecordHistory delegates to data manager', () {
      expect(controller.shouldRecordHistory(isPrivate: true), isFalse);
      expect(controller.shouldRecordHistory(isPrivate: false), isTrue);
    });

    test('shouldPersistTab delegates to data manager', () {
      expect(controller.shouldPersistTab(isPrivate: true), isFalse);
      expect(controller.shouldPersistTab(isPrivate: false), isTrue);
    });

    test('clearAllPrivateData resets state and calls cleanup', () async {
      controller.updatePrivateTabCount(2);
      await controller.clearAllPrivateData();

      expect(controller.state, equals(const PrivateSessionState()));
      expect(fakeManager.clearCallCount, 1);
    });
  });

  group('PrivateSessionState', () {
    test('default state is inactive', () {
      const s = PrivateSessionState();
      expect(s.isActive, isFalse);
      expect(s.privateTabCount, 0);
      expect(s.sessionStartedAt, isNull);
    });

    test('copyWith updates fields', () {
      const s = PrivateSessionState();
      final updated = s.copyWith(isActive: true, privateTabCount: 3);

      expect(updated.isActive, isTrue);
      expect(updated.privateTabCount, 3);
    });

    test('equality works', () {
      const a = PrivateSessionState(isActive: true, privateTabCount: 2);
      const b = PrivateSessionState(isActive: true, privateTabCount: 2);
      expect(a, equals(b));
    });

    test('different states are not equal', () {
      const a = PrivateSessionState(isActive: true, privateTabCount: 1);
      const b = PrivateSessionState(isActive: false, privateTabCount: 0);
      expect(a, isNot(equals(b)));
    });
  });
}
