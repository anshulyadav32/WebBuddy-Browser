import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/history/data/history_repository.dart';
import 'package:web_buddy/features/history/presentation/history_controller.dart';

void main() {
  group('HistoryController', () {
    late HistoryRepository repo;
    late HistoryController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = HistoryRepository(StorageService(prefs));
      controller = HistoryController(repo);
    });

    test('initial state is empty', () {
      expect(controller.state, isEmpty);
    });

    test('add history item updates state', () async {
      await controller.addHistoryItem(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );

      expect(controller.state.length, 1);
      expect(controller.state.first.url, 'https://flutter.dev');
      expect(controller.state.first.title, 'Flutter');
    });

    test('delete history item updates state', () async {
      await controller.addHistoryItem(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );
      final id = controller.state.first.id;

      await controller.deleteHistoryItem(id);

      expect(controller.state, isEmpty);
    });

    test('clear all updates state', () async {
      await controller.addHistoryItem(url: 'https://a.com', title: 'A');
      await controller.addHistoryItem(url: 'https://b.com', title: 'B');
      expect(controller.state.length, 2);

      await controller.clearAll();

      expect(controller.state, isEmpty);
    });

    test('newest-first ordering preserved', () async {
      await controller.addHistoryItem(url: 'https://a.com', title: 'A');
      // Small delay to ensure different timestamps
      await controller.addHistoryItem(url: 'https://b.com', title: 'B');

      // The second item should be first (newest)
      expect(controller.state.first.url, 'https://b.com');
    });
  });
}
