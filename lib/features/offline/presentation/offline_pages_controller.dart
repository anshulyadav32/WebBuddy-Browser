import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../settings/presentation/settings_controller.dart';
import '../data/offline_pages_repository.dart';
import '../domain/offline_page.dart';

final offlinePagesRepositoryProvider = Provider<OfflinePagesRepository>((ref) {
  return OfflinePagesRepository(ref.watch(storageServiceProvider));
});

final offlinePagesControllerProvider =
    StateNotifierProvider<OfflinePagesController, List<OfflinePage>>((ref) {
      return OfflinePagesController(ref.watch(offlinePagesRepositoryProvider));
    });

class OfflinePagesController extends StateNotifier<List<OfflinePage>> {
  OfflinePagesController(this._repo) : super(_repo.loadAll());

  final OfflinePagesRepository _repo;

  Future<void> addSavedPage({
    required String url,
    required String title,
    required String filePath,
  }) async {
    final page = OfflinePage(
      id: const Uuid().v4(),
      url: url,
      title: title.trim().isEmpty ? url : title.trim(),
      filePath: filePath,
      savedAt: DateTime.now(),
    );

    state = [page, ...state.where((item) => item.filePath != filePath)];
    await _repo.saveAll(state);
  }

  Future<void> remove(String id) async {
    OfflinePage? target;
    for (final item in state) {
      if (item.id == id) {
        target = item;
        break;
      }
    }
    state = state.where((item) => item.id != id).toList();
    await _repo.saveAll(state);

    if (target != null) {
      final file = File(target.filePath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {
          // Keep metadata removal even if file deletion fails.
        }
      }
    }
  }

  Future<void> clearAll() async {
    final pages = [...state];
    state = [];
    await _repo.clearAll();

    for (final page in pages) {
      final file = File(page.filePath);
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (_) {
          // Ignore individual file deletion failures.
        }
      }
    }
  }
}
