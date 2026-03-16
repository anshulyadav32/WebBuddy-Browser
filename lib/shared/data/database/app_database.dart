import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Bookmarks table.
class Bookmarks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text()();
  TextColumn get favicon => text().nullable()();
  IntColumn get parentFolderId => integer().nullable()();
  BoolColumn get isFolder => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// History table.
class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get url => text()();
  TextColumn get favicon => text().nullable()();
  DateTimeColumn get visitedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get visitCount => integer().withDefault(const Constant(1))();
}

/// Downloads table.
class Downloads extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().withDefault(const Constant(0))();
  TextColumn get mimeType => text().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get startedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// Site permissions table.
class SitePermissions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get host => text()();
  TextColumn get permission => text()();
  // 0 = denied, 1 = granted, 2 = ask
  IntColumn get value => integer().withDefault(const Constant(2))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {host, permission},
  ];
}

/// Blocked requests log (for privacy shields).
class BlockedRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pageUrl => text()();
  TextColumn get blockedUrl => text()();
  TextColumn get filterRule => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('tracker'))();
  DateTimeColumn get blockedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Bookmarks,
  HistoryEntries,
  Downloads,
  SitePermissions,
  BlockedRequests,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ----- Bookmarks -----

  Future<List<Bookmark>> getAllBookmarks() => select(bookmarks).get();

  Future<List<Bookmark>> getBookmarksInFolder(int? folderId) {
    return (select(bookmarks)
          ..where((b) => folderId == null
              ? b.parentFolderId.isNull()
              : b.parentFolderId.equals(folderId))
          ..orderBy([(b) => OrderingTerm.asc(b.sortOrder)]))
        .get();
  }

  Future<int> insertBookmark(BookmarksCompanion entry) =>
      into(bookmarks).insert(entry);

  Future<bool> updateBookmark(BookmarksCompanion entry) =>
      update(bookmarks).replace(Bookmark(
        id: entry.id.value,
        title: entry.title.value,
        url: entry.url.value,
        favicon: entry.favicon.value,
        parentFolderId: entry.parentFolderId.value,
        isFolder: entry.isFolder.value,
        createdAt: entry.createdAt.value,
        sortOrder: entry.sortOrder.value,
      ));

  Future<int> deleteBookmark(int id) =>
      (delete(bookmarks)..where((b) => b.id.equals(id))).go();

  Future<bool> isBookmarked(String url) async {
    final count = await (select(bookmarks)..where((b) => b.url.equals(url))).get();
    return count.isNotEmpty;
  }

  // ----- History -----

  Future<List<HistoryEntry>> getRecentHistory({int limit = 100}) {
    return (select(historyEntries)
          ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)])
          ..limit(limit))
        .get();
  }

  Future<List<HistoryEntry>> searchHistory(String query) {
    return (select(historyEntries)
          ..where((h) => h.title.like('%$query%') | h.url.like('%$query%'))
          ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)])
          ..limit(50))
        .get();
  }

  Future<int> insertHistoryEntry(HistoryEntriesCompanion entry) =>
      into(historyEntries).insert(entry);

  Future<void> deleteHistoryEntry(int id) =>
      (delete(historyEntries)..where((h) => h.id.equals(id))).go();

  Future<void> clearHistory() => delete(historyEntries).go();

  Future<void> clearHistoryBefore(DateTime date) =>
      (delete(historyEntries)..where((h) => h.visitedAt.isSmallerThanValue(date)))
          .go();

  // ----- Downloads -----

  Future<List<Download>> getAllDownloads() {
    return (select(downloads)
          ..orderBy([(d) => OrderingTerm.desc(d.startedAt)]))
        .get();
  }

  Future<int> insertDownload(DownloadsCompanion entry) =>
      into(downloads).insert(entry);

  Future<void> updateDownloadStatus(int id, int status, {int? downloadedBytes}) {
    return (update(downloads)..where((d) => d.id.equals(id))).write(
      DownloadsCompanion(
        status: Value(status),
        downloadedBytes: downloadedBytes != null
            ? Value(downloadedBytes)
            : const Value.absent(),
        completedAt: status == 2 ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteDownload(int id) =>
      (delete(downloads)..where((d) => d.id.equals(id))).go();

  // ----- Site Permissions -----

  Future<List<SitePermission>> getPermissionsForHost(String host) {
    return (select(sitePermissions)..where((s) => s.host.equals(host))).get();
  }

  Future<void> setPermission(String host, String permission, int value) {
    return into(sitePermissions).insertOnConflictUpdate(
      SitePermissionsCompanion.insert(
        host: host,
        permission: permission,
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearSitePermissions() => delete(sitePermissions).go();

  // ----- Blocked Requests -----

  Future<int> insertBlockedRequest(BlockedRequestsCompanion entry) =>
      into(blockedRequests).insert(entry);

  Future<List<BlockedRequest>> getBlockedRequestsForPage(String pageUrl) {
    return (select(blockedRequests)
          ..where((b) => b.pageUrl.equals(pageUrl))
          ..orderBy([(b) => OrderingTerm.desc(b.blockedAt)]))
        .get();
  }

  Future<int> getBlockedCount(String pageUrl) async {
    final result = await (select(blockedRequests)
          ..where((b) => b.pageUrl.equals(pageUrl)))
        .get();
    return result.length;
  }

  Future<void> clearBlockedRequests() => delete(blockedRequests).go();

  // ----- Clear all data -----

  Future<void> clearAllBrowsingData({
    bool clearHistory = true,
    bool clearBookmarks = false,
    bool clearDownloads = false,
    bool clearPermissions = true,
    bool clearBlockedRequests = true,
  }) async {
    await transaction(() async {
      if (clearHistory) await delete(historyEntries).go();
      if (clearBookmarks) await delete(bookmarks).go();
      if (clearDownloads) await delete(downloads).go();
      if (clearPermissions) await delete(sitePermissions).go();
      if (clearBlockedRequests) await delete(blockedRequests).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'web_buddy.db'));
    return NativeDatabase.createInBackground(file);
  });
}
