import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_buddy/shared/data/database/app_database.dart';

/// Database provider — single instance across the app.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
