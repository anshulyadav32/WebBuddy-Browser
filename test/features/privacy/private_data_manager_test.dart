import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/private_data_manager.dart';

void main() {
  group('PrivateDataManager', () {
    late PrivateDataManager manager;

    setUp(() {
      // Don't pass a real cookie manager in tests — the methods
      // under test here are synchronous policy checks.
      manager = PrivateDataManager();
    });

    test('shouldRecordHistory returns false for private', () {
      expect(manager.shouldRecordHistory(isPrivate: true), isFalse);
    });

    test('shouldRecordHistory returns true for non-private', () {
      expect(manager.shouldRecordHistory(isPrivate: false), isTrue);
    });

    test('shouldPersistTab returns false for private', () {
      expect(manager.shouldPersistTab(isPrivate: true), isFalse);
    });

    test('shouldPersistTab returns true for non-private', () {
      expect(manager.shouldPersistTab(isPrivate: false), isTrue);
    });
  });
}
