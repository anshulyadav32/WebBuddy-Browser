import 'package:flutter_test/flutter_test.dart';
import 'package:web_buddy/features/privacy/data/filter_list_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FilterListRepository', () {
    test('loadRules reads bundled filter rules', () async {
      final repository = FilterListRepository();

      final rules = await repository.loadRules();

      expect(rules, isNotEmpty);
    });

    test('loadRules returns cached list instance until invalidated', () async {
      final repository = FilterListRepository();

      final first = await repository.loadRules();
      final second = await repository.loadRules();

      expect(identical(first, second), isTrue);
    });

    test('invalidateCache forces reload with a new list instance', () async {
      final repository = FilterListRepository();

      final first = await repository.loadRules();
      repository.invalidateCache();
      final second = await repository.loadRules();

      expect(identical(first, second), isFalse);
      expect(second, isNotEmpty);
    });
  });
}
