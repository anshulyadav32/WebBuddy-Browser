import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:web_buddy/core/services/storage_service.dart';
import 'package:web_buddy/features/offline/data/offline_pages_repository.dart';
import 'package:web_buddy/features/offline/domain/offline_page.dart';
import 'package:web_buddy/features/offline/presentation/offline_pages_controller.dart';
import 'package:web_buddy/features/offline/presentation/offline_pages_screen.dart';

Future<OfflinePagesController> _seededController(
  List<OfflinePage> items,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final repo = OfflinePagesRepository(StorageService(prefs));
  await repo.saveAll(items);
  return OfflinePagesController(repo);
}

void main() {
  group('OfflinePagesScreen', () {
    testWidgets('shows empty state', (tester) async {
      final controller = await _seededController([]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            offlinePagesControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(home: OfflinePagesScreen()),
        ),
      );

      expect(find.text('No offline pages yet'), findsOneWidget);
    });

    testWidgets('shows saved pages list', (tester) async {
      final items = [
        OfflinePage(
          id: '1',
          url: 'https://example.com',
          title: 'Example',
          filePath: '/tmp/example.html',
          savedAt: DateTime(2026, 1, 1),
        ),
      ];
      final controller = await _seededController(items);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            offlinePagesControllerProvider.overrideWith((ref) => controller),
          ],
          child: const MaterialApp(home: OfflinePagesScreen()),
        ),
      );

      expect(find.text('Offline pages'), findsOneWidget);
      expect(find.text('Example'), findsOneWidget);
      expect(find.text('https://example.com'), findsOneWidget);
    });
  });
}
