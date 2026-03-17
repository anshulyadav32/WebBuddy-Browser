import 'package:flutter_test/flutter_test.dart';

import 'package:web_buddy/features/privacy/data/private_data_manager.dart';

/// Tests for private session cleanup edge cases and failure resilience.
///
/// Note: clearPrivateSessionData() internally creates a WebViewCookieManager
/// which requires WebViewPlatform.instance to be set. In unit tests without
/// platform channel setup, we can only test the policy/query methods.
void main() {
  group('PrivateDataManager – policy queries', () {
    test('shouldRecordHistory returns false for private tabs', () {
      final manager = PrivateDataManager();

      expect(manager.shouldRecordHistory(isPrivate: true), isFalse);
      expect(manager.shouldRecordHistory(isPrivate: false), isTrue);
    });

    test('shouldPersistTab returns false for private tabs', () {
      final manager = PrivateDataManager();

      expect(manager.shouldPersistTab(isPrivate: true), isFalse);
      expect(manager.shouldPersistTab(isPrivate: false), isTrue);
    });
  });
}
