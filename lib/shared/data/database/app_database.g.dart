// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faviconMeta = const VerificationMeta(
    'favicon',
  );
  @override
  late final GeneratedColumn<String> favicon = GeneratedColumn<String>(
    'favicon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentFolderIdMeta = const VerificationMeta(
    'parentFolderId',
  );
  @override
  late final GeneratedColumn<int> parentFolderId = GeneratedColumn<int>(
    'parent_folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFolderMeta = const VerificationMeta(
    'isFolder',
  );
  @override
  late final GeneratedColumn<bool> isFolder = GeneratedColumn<bool>(
    'is_folder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_folder" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    favicon,
    parentFolderId,
    isFolder,
    createdAt,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('favicon')) {
      context.handle(
        _faviconMeta,
        favicon.isAcceptableOrUnknown(data['favicon']!, _faviconMeta),
      );
    }
    if (data.containsKey('parent_folder_id')) {
      context.handle(
        _parentFolderIdMeta,
        parentFolderId.isAcceptableOrUnknown(
          data['parent_folder_id']!,
          _parentFolderIdMeta,
        ),
      );
    }
    if (data.containsKey('is_folder')) {
      context.handle(
        _isFolderMeta,
        isFolder.isAcceptableOrUnknown(data['is_folder']!, _isFolderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      favicon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon'],
      ),
      parentFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_folder_id'],
      ),
      isFolder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_folder'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final int id;
  final String title;
  final String url;
  final String? favicon;
  final int? parentFolderId;
  final bool isFolder;
  final DateTime createdAt;
  final int sortOrder;
  const Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.favicon,
    this.parentFolderId,
    required this.isFolder,
    required this.createdAt,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || favicon != null) {
      map['favicon'] = Variable<String>(favicon);
    }
    if (!nullToAbsent || parentFolderId != null) {
      map['parent_folder_id'] = Variable<int>(parentFolderId);
    }
    map['is_folder'] = Variable<bool>(isFolder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      favicon: favicon == null && nullToAbsent
          ? const Value.absent()
          : Value(favicon),
      parentFolderId: parentFolderId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentFolderId),
      isFolder: Value(isFolder),
      createdAt: Value(createdAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      favicon: serializer.fromJson<String?>(json['favicon']),
      parentFolderId: serializer.fromJson<int?>(json['parentFolderId']),
      isFolder: serializer.fromJson<bool>(json['isFolder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'favicon': serializer.toJson<String?>(favicon),
      'parentFolderId': serializer.toJson<int?>(parentFolderId),
      'isFolder': serializer.toJson<bool>(isFolder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Bookmark copyWith({
    int? id,
    String? title,
    String? url,
    Value<String?> favicon = const Value.absent(),
    Value<int?> parentFolderId = const Value.absent(),
    bool? isFolder,
    DateTime? createdAt,
    int? sortOrder,
  }) => Bookmark(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    favicon: favicon.present ? favicon.value : this.favicon,
    parentFolderId: parentFolderId.present
        ? parentFolderId.value
        : this.parentFolderId,
    isFolder: isFolder ?? this.isFolder,
    createdAt: createdAt ?? this.createdAt,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      favicon: data.favicon.present ? data.favicon.value : this.favicon,
      parentFolderId: data.parentFolderId.present
          ? data.parentFolderId.value
          : this.parentFolderId,
      isFolder: data.isFolder.present ? data.isFolder.value : this.isFolder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('favicon: $favicon, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('isFolder: $isFolder, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    url,
    favicon,
    parentFolderId,
    isFolder,
    createdAt,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.favicon == this.favicon &&
          other.parentFolderId == this.parentFolderId &&
          other.isFolder == this.isFolder &&
          other.createdAt == this.createdAt &&
          other.sortOrder == this.sortOrder);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> favicon;
  final Value<int?> parentFolderId;
  final Value<bool> isFolder;
  final Value<DateTime> createdAt;
  final Value<int> sortOrder;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.favicon = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.isFolder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  BookmarksCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    required String url,
    this.favicon = const Value.absent(),
    this.parentFolderId = const Value.absent(),
    this.isFolder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : url = Value(url);
  static Insertable<Bookmark> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? favicon,
    Expression<int>? parentFolderId,
    Expression<bool>? isFolder,
    Expression<DateTime>? createdAt,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (favicon != null) 'favicon': favicon,
      if (parentFolderId != null) 'parent_folder_id': parentFolderId,
      if (isFolder != null) 'is_folder': isFolder,
      if (createdAt != null) 'created_at': createdAt,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  BookmarksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? favicon,
    Value<int?>? parentFolderId,
    Value<bool>? isFolder,
    Value<DateTime>? createdAt,
    Value<int>? sortOrder,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      favicon: favicon ?? this.favicon,
      parentFolderId: parentFolderId ?? this.parentFolderId,
      isFolder: isFolder ?? this.isFolder,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (favicon.present) {
      map['favicon'] = Variable<String>(favicon.value);
    }
    if (parentFolderId.present) {
      map['parent_folder_id'] = Variable<int>(parentFolderId.value);
    }
    if (isFolder.present) {
      map['is_folder'] = Variable<bool>(isFolder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('favicon: $favicon, ')
          ..write('parentFolderId: $parentFolderId, ')
          ..write('isFolder: $isFolder, ')
          ..write('createdAt: $createdAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $HistoryEntriesTable extends HistoryEntries
    with TableInfo<$HistoryEntriesTable, HistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faviconMeta = const VerificationMeta(
    'favicon',
  );
  @override
  late final GeneratedColumn<String> favicon = GeneratedColumn<String>(
    'favicon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _visitCountMeta = const VerificationMeta(
    'visitCount',
  );
  @override
  late final GeneratedColumn<int> visitCount = GeneratedColumn<int>(
    'visit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    url,
    favicon,
    visitedAt,
    visitCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('favicon')) {
      context.handle(
        _faviconMeta,
        favicon.isAcceptableOrUnknown(data['favicon']!, _faviconMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    }
    if (data.containsKey('visit_count')) {
      context.handle(
        _visitCountMeta,
        visitCount.isAcceptableOrUnknown(data['visit_count']!, _visitCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      favicon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon'],
      ),
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
      visitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}visit_count'],
      )!,
    );
  }

  @override
  $HistoryEntriesTable createAlias(String alias) {
    return $HistoryEntriesTable(attachedDatabase, alias);
  }
}

class HistoryEntry extends DataClass implements Insertable<HistoryEntry> {
  final int id;
  final String title;
  final String url;
  final String? favicon;
  final DateTime visitedAt;
  final int visitCount;
  const HistoryEntry({
    required this.id,
    required this.title,
    required this.url,
    this.favicon,
    required this.visitedAt,
    required this.visitCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || favicon != null) {
      map['favicon'] = Variable<String>(favicon);
    }
    map['visited_at'] = Variable<DateTime>(visitedAt);
    map['visit_count'] = Variable<int>(visitCount);
    return map;
  }

  HistoryEntriesCompanion toCompanion(bool nullToAbsent) {
    return HistoryEntriesCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      favicon: favicon == null && nullToAbsent
          ? const Value.absent()
          : Value(favicon),
      visitedAt: Value(visitedAt),
      visitCount: Value(visitCount),
    );
  }

  factory HistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      favicon: serializer.fromJson<String?>(json['favicon']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
      visitCount: serializer.fromJson<int>(json['visitCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'favicon': serializer.toJson<String?>(favicon),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
      'visitCount': serializer.toJson<int>(visitCount),
    };
  }

  HistoryEntry copyWith({
    int? id,
    String? title,
    String? url,
    Value<String?> favicon = const Value.absent(),
    DateTime? visitedAt,
    int? visitCount,
  }) => HistoryEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    url: url ?? this.url,
    favicon: favicon.present ? favicon.value : this.favicon,
    visitedAt: visitedAt ?? this.visitedAt,
    visitCount: visitCount ?? this.visitCount,
  );
  HistoryEntry copyWithCompanion(HistoryEntriesCompanion data) {
    return HistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      favicon: data.favicon.present ? data.favicon.value : this.favicon,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
      visitCount: data.visitCount.present
          ? data.visitCount.value
          : this.visitCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('favicon: $favicon, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('visitCount: $visitCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, url, favicon, visitedAt, visitCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.favicon == this.favicon &&
          other.visitedAt == this.visitedAt &&
          other.visitCount == this.visitCount);
}

class HistoryEntriesCompanion extends UpdateCompanion<HistoryEntry> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> favicon;
  final Value<DateTime> visitedAt;
  final Value<int> visitCount;
  const HistoryEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.favicon = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.visitCount = const Value.absent(),
  });
  HistoryEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    required String url,
    this.favicon = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.visitCount = const Value.absent(),
  }) : url = Value(url);
  static Insertable<HistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? favicon,
    Expression<DateTime>? visitedAt,
    Expression<int>? visitCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (favicon != null) 'favicon': favicon,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (visitCount != null) 'visit_count': visitCount,
    });
  }

  HistoryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? url,
    Value<String?>? favicon,
    Value<DateTime>? visitedAt,
    Value<int>? visitCount,
  }) {
    return HistoryEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      favicon: favicon ?? this.favicon,
      visitedAt: visitedAt ?? this.visitedAt,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (favicon.present) {
      map['favicon'] = Variable<String>(favicon.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (visitCount.present) {
      map['visit_count'] = Variable<int>(visitCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('favicon: $favicon, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('visitCount: $visitCount')
          ..write(')'))
        .toString();
  }
}

class $DownloadsTable extends Downloads
    with TableInfo<$DownloadsTable, Download> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _downloadedBytesMeta = const VerificationMeta(
    'downloadedBytes',
  );
  @override
  late final GeneratedColumn<int> downloadedBytes = GeneratedColumn<int>(
    'downloaded_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    fileName,
    filePath,
    fileSize,
    mimeType,
    status,
    downloadedBytes,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Download> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('downloaded_bytes')) {
      context.handle(
        _downloadedBytesMeta,
        downloadedBytes.isAcceptableOrUnknown(
          data['downloaded_bytes']!,
          _downloadedBytesMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Download map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Download(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      downloadedBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_bytes'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $DownloadsTable createAlias(String alias) {
    return $DownloadsTable(attachedDatabase, alias);
  }
}

class Download extends DataClass implements Insertable<Download> {
  final int id;
  final String url;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String? mimeType;
  final int status;
  final int downloadedBytes;
  final DateTime startedAt;
  final DateTime? completedAt;
  const Download({
    required this.id,
    required this.url,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    this.mimeType,
    required this.status,
    required this.downloadedBytes,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    map['status'] = Variable<int>(status);
    map['downloaded_bytes'] = Variable<int>(downloadedBytes);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  DownloadsCompanion toCompanion(bool nullToAbsent) {
    return DownloadsCompanion(
      id: Value(id),
      url: Value(url),
      fileName: Value(fileName),
      filePath: Value(filePath),
      fileSize: Value(fileSize),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      status: Value(status),
      downloadedBytes: Value(downloadedBytes),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory Download.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Download(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      status: serializer.fromJson<int>(json['status']),
      downloadedBytes: serializer.fromJson<int>(json['downloadedBytes']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'fileSize': serializer.toJson<int>(fileSize),
      'mimeType': serializer.toJson<String?>(mimeType),
      'status': serializer.toJson<int>(status),
      'downloadedBytes': serializer.toJson<int>(downloadedBytes),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  Download copyWith({
    int? id,
    String? url,
    String? fileName,
    String? filePath,
    int? fileSize,
    Value<String?> mimeType = const Value.absent(),
    int? status,
    int? downloadedBytes,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => Download(
    id: id ?? this.id,
    url: url ?? this.url,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    fileSize: fileSize ?? this.fileSize,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    status: status ?? this.status,
    downloadedBytes: downloadedBytes ?? this.downloadedBytes,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  Download copyWithCompanion(DownloadsCompanion data) {
    return Download(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      status: data.status.present ? data.status.value : this.status,
      downloadedBytes: data.downloadedBytes.present
          ? data.downloadedBytes.value
          : this.downloadedBytes,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Download(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('status: $status, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    fileName,
    filePath,
    fileSize,
    mimeType,
    status,
    downloadedBytes,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Download &&
          other.id == this.id &&
          other.url == this.url &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.fileSize == this.fileSize &&
          other.mimeType == this.mimeType &&
          other.status == this.status &&
          other.downloadedBytes == this.downloadedBytes &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class DownloadsCompanion extends UpdateCompanion<Download> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<int> fileSize;
  final Value<String?> mimeType;
  final Value<int> status;
  final Value<int> downloadedBytes;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  const DownloadsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  DownloadsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String fileName,
    required String filePath,
    this.fileSize = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.status = const Value.absent(),
    this.downloadedBytes = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : url = Value(url),
       fileName = Value(fileName),
       filePath = Value(filePath);
  static Insertable<Download> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<int>? fileSize,
    Expression<String>? mimeType,
    Expression<int>? status,
    Expression<int>? downloadedBytes,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (fileSize != null) 'file_size': fileSize,
      if (mimeType != null) 'mime_type': mimeType,
      if (status != null) 'status': status,
      if (downloadedBytes != null) 'downloaded_bytes': downloadedBytes,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  DownloadsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<int>? fileSize,
    Value<String?>? mimeType,
    Value<int>? status,
    Value<int>? downloadedBytes,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
  }) {
    return DownloadsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (downloadedBytes.present) {
      map['downloaded_bytes'] = Variable<int>(downloadedBytes.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileSize: $fileSize, ')
          ..write('mimeType: $mimeType, ')
          ..write('status: $status, ')
          ..write('downloadedBytes: $downloadedBytes, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $SitePermissionsTable extends SitePermissions
    with TableInfo<$SitePermissionsTable, SitePermission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitePermissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionMeta = const VerificationMeta(
    'permission',
  );
  @override
  late final GeneratedColumn<String> permission = GeneratedColumn<String>(
    'permission',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    host,
    permission,
    value,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'site_permissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SitePermission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('permission')) {
      context.handle(
        _permissionMeta,
        permission.isAcceptableOrUnknown(data['permission']!, _permissionMeta),
      );
    } else if (isInserting) {
      context.missing(_permissionMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {host, permission},
  ];
  @override
  SitePermission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SitePermission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      permission: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permission'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SitePermissionsTable createAlias(String alias) {
    return $SitePermissionsTable(attachedDatabase, alias);
  }
}

class SitePermission extends DataClass implements Insertable<SitePermission> {
  final int id;
  final String host;
  final String permission;
  final int value;
  final DateTime updatedAt;
  const SitePermission({
    required this.id,
    required this.host,
    required this.permission,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['host'] = Variable<String>(host);
    map['permission'] = Variable<String>(permission);
    map['value'] = Variable<int>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SitePermissionsCompanion toCompanion(bool nullToAbsent) {
    return SitePermissionsCompanion(
      id: Value(id),
      host: Value(host),
      permission: Value(permission),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SitePermission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SitePermission(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String>(json['host']),
      permission: serializer.fromJson<String>(json['permission']),
      value: serializer.fromJson<int>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String>(host),
      'permission': serializer.toJson<String>(permission),
      'value': serializer.toJson<int>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SitePermission copyWith({
    int? id,
    String? host,
    String? permission,
    int? value,
    DateTime? updatedAt,
  }) => SitePermission(
    id: id ?? this.id,
    host: host ?? this.host,
    permission: permission ?? this.permission,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SitePermission copyWithCompanion(SitePermissionsCompanion data) {
    return SitePermission(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
      permission: data.permission.present
          ? data.permission.value
          : this.permission,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SitePermission(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('permission: $permission, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, host, permission, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SitePermission &&
          other.id == this.id &&
          other.host == this.host &&
          other.permission == this.permission &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SitePermissionsCompanion extends UpdateCompanion<SitePermission> {
  final Value<int> id;
  final Value<String> host;
  final Value<String> permission;
  final Value<int> value;
  final Value<DateTime> updatedAt;
  const SitePermissionsCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.permission = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SitePermissionsCompanion.insert({
    this.id = const Value.absent(),
    required String host,
    required String permission,
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : host = Value(host),
       permission = Value(permission);
  static Insertable<SitePermission> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<String>? permission,
    Expression<int>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (permission != null) 'permission': permission,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SitePermissionsCompanion copyWith({
    Value<int>? id,
    Value<String>? host,
    Value<String>? permission,
    Value<int>? value,
    Value<DateTime>? updatedAt,
  }) {
    return SitePermissionsCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      permission: permission ?? this.permission,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (permission.present) {
      map['permission'] = Variable<String>(permission.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitePermissionsCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('permission: $permission, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BlockedRequestsTable extends BlockedRequests
    with TableInfo<$BlockedRequestsTable, BlockedRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlockedRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageUrlMeta = const VerificationMeta(
    'pageUrl',
  );
  @override
  late final GeneratedColumn<String> pageUrl = GeneratedColumn<String>(
    'page_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blockedUrlMeta = const VerificationMeta(
    'blockedUrl',
  );
  @override
  late final GeneratedColumn<String> blockedUrl = GeneratedColumn<String>(
    'blocked_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterRuleMeta = const VerificationMeta(
    'filterRule',
  );
  @override
  late final GeneratedColumn<String> filterRule = GeneratedColumn<String>(
    'filter_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tracker'),
  );
  static const VerificationMeta _blockedAtMeta = const VerificationMeta(
    'blockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> blockedAt = GeneratedColumn<DateTime>(
    'blocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pageUrl,
    blockedUrl,
    filterRule,
    category,
    blockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blocked_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<BlockedRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page_url')) {
      context.handle(
        _pageUrlMeta,
        pageUrl.isAcceptableOrUnknown(data['page_url']!, _pageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_pageUrlMeta);
    }
    if (data.containsKey('blocked_url')) {
      context.handle(
        _blockedUrlMeta,
        blockedUrl.isAcceptableOrUnknown(data['blocked_url']!, _blockedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_blockedUrlMeta);
    }
    if (data.containsKey('filter_rule')) {
      context.handle(
        _filterRuleMeta,
        filterRule.isAcceptableOrUnknown(data['filter_rule']!, _filterRuleMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('blocked_at')) {
      context.handle(
        _blockedAtMeta,
        blockedAt.isAcceptableOrUnknown(data['blocked_at']!, _blockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BlockedRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BlockedRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_url'],
      )!,
      blockedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_url'],
      )!,
      filterRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_rule'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      blockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}blocked_at'],
      )!,
    );
  }

  @override
  $BlockedRequestsTable createAlias(String alias) {
    return $BlockedRequestsTable(attachedDatabase, alias);
  }
}

class BlockedRequest extends DataClass implements Insertable<BlockedRequest> {
  final int id;
  final String pageUrl;
  final String blockedUrl;
  final String? filterRule;
  final String category;
  final DateTime blockedAt;
  const BlockedRequest({
    required this.id,
    required this.pageUrl,
    required this.blockedUrl,
    this.filterRule,
    required this.category,
    required this.blockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page_url'] = Variable<String>(pageUrl);
    map['blocked_url'] = Variable<String>(blockedUrl);
    if (!nullToAbsent || filterRule != null) {
      map['filter_rule'] = Variable<String>(filterRule);
    }
    map['category'] = Variable<String>(category);
    map['blocked_at'] = Variable<DateTime>(blockedAt);
    return map;
  }

  BlockedRequestsCompanion toCompanion(bool nullToAbsent) {
    return BlockedRequestsCompanion(
      id: Value(id),
      pageUrl: Value(pageUrl),
      blockedUrl: Value(blockedUrl),
      filterRule: filterRule == null && nullToAbsent
          ? const Value.absent()
          : Value(filterRule),
      category: Value(category),
      blockedAt: Value(blockedAt),
    );
  }

  factory BlockedRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BlockedRequest(
      id: serializer.fromJson<int>(json['id']),
      pageUrl: serializer.fromJson<String>(json['pageUrl']),
      blockedUrl: serializer.fromJson<String>(json['blockedUrl']),
      filterRule: serializer.fromJson<String?>(json['filterRule']),
      category: serializer.fromJson<String>(json['category']),
      blockedAt: serializer.fromJson<DateTime>(json['blockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pageUrl': serializer.toJson<String>(pageUrl),
      'blockedUrl': serializer.toJson<String>(blockedUrl),
      'filterRule': serializer.toJson<String?>(filterRule),
      'category': serializer.toJson<String>(category),
      'blockedAt': serializer.toJson<DateTime>(blockedAt),
    };
  }

  BlockedRequest copyWith({
    int? id,
    String? pageUrl,
    String? blockedUrl,
    Value<String?> filterRule = const Value.absent(),
    String? category,
    DateTime? blockedAt,
  }) => BlockedRequest(
    id: id ?? this.id,
    pageUrl: pageUrl ?? this.pageUrl,
    blockedUrl: blockedUrl ?? this.blockedUrl,
    filterRule: filterRule.present ? filterRule.value : this.filterRule,
    category: category ?? this.category,
    blockedAt: blockedAt ?? this.blockedAt,
  );
  BlockedRequest copyWithCompanion(BlockedRequestsCompanion data) {
    return BlockedRequest(
      id: data.id.present ? data.id.value : this.id,
      pageUrl: data.pageUrl.present ? data.pageUrl.value : this.pageUrl,
      blockedUrl: data.blockedUrl.present
          ? data.blockedUrl.value
          : this.blockedUrl,
      filterRule: data.filterRule.present
          ? data.filterRule.value
          : this.filterRule,
      category: data.category.present ? data.category.value : this.category,
      blockedAt: data.blockedAt.present ? data.blockedAt.value : this.blockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BlockedRequest(')
          ..write('id: $id, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('blockedUrl: $blockedUrl, ')
          ..write('filterRule: $filterRule, ')
          ..write('category: $category, ')
          ..write('blockedAt: $blockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pageUrl, blockedUrl, filterRule, category, blockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BlockedRequest &&
          other.id == this.id &&
          other.pageUrl == this.pageUrl &&
          other.blockedUrl == this.blockedUrl &&
          other.filterRule == this.filterRule &&
          other.category == this.category &&
          other.blockedAt == this.blockedAt);
}

class BlockedRequestsCompanion extends UpdateCompanion<BlockedRequest> {
  final Value<int> id;
  final Value<String> pageUrl;
  final Value<String> blockedUrl;
  final Value<String?> filterRule;
  final Value<String> category;
  final Value<DateTime> blockedAt;
  const BlockedRequestsCompanion({
    this.id = const Value.absent(),
    this.pageUrl = const Value.absent(),
    this.blockedUrl = const Value.absent(),
    this.filterRule = const Value.absent(),
    this.category = const Value.absent(),
    this.blockedAt = const Value.absent(),
  });
  BlockedRequestsCompanion.insert({
    this.id = const Value.absent(),
    required String pageUrl,
    required String blockedUrl,
    this.filterRule = const Value.absent(),
    this.category = const Value.absent(),
    this.blockedAt = const Value.absent(),
  }) : pageUrl = Value(pageUrl),
       blockedUrl = Value(blockedUrl);
  static Insertable<BlockedRequest> custom({
    Expression<int>? id,
    Expression<String>? pageUrl,
    Expression<String>? blockedUrl,
    Expression<String>? filterRule,
    Expression<String>? category,
    Expression<DateTime>? blockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pageUrl != null) 'page_url': pageUrl,
      if (blockedUrl != null) 'blocked_url': blockedUrl,
      if (filterRule != null) 'filter_rule': filterRule,
      if (category != null) 'category': category,
      if (blockedAt != null) 'blocked_at': blockedAt,
    });
  }

  BlockedRequestsCompanion copyWith({
    Value<int>? id,
    Value<String>? pageUrl,
    Value<String>? blockedUrl,
    Value<String?>? filterRule,
    Value<String>? category,
    Value<DateTime>? blockedAt,
  }) {
    return BlockedRequestsCompanion(
      id: id ?? this.id,
      pageUrl: pageUrl ?? this.pageUrl,
      blockedUrl: blockedUrl ?? this.blockedUrl,
      filterRule: filterRule ?? this.filterRule,
      category: category ?? this.category,
      blockedAt: blockedAt ?? this.blockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pageUrl.present) {
      map['page_url'] = Variable<String>(pageUrl.value);
    }
    if (blockedUrl.present) {
      map['blocked_url'] = Variable<String>(blockedUrl.value);
    }
    if (filterRule.present) {
      map['filter_rule'] = Variable<String>(filterRule.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (blockedAt.present) {
      map['blocked_at'] = Variable<DateTime>(blockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlockedRequestsCompanion(')
          ..write('id: $id, ')
          ..write('pageUrl: $pageUrl, ')
          ..write('blockedUrl: $blockedUrl, ')
          ..write('filterRule: $filterRule, ')
          ..write('category: $category, ')
          ..write('blockedAt: $blockedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $HistoryEntriesTable historyEntries = $HistoryEntriesTable(this);
  late final $DownloadsTable downloads = $DownloadsTable(this);
  late final $SitePermissionsTable sitePermissions = $SitePermissionsTable(
    this,
  );
  late final $BlockedRequestsTable blockedRequests = $BlockedRequestsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bookmarks,
    historyEntries,
    downloads,
    sitePermissions,
    blockedRequests,
  ];
}

typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> title,
      required String url,
      Value<String?> favicon,
      Value<int?> parentFolderId,
      Value<bool> isFolder,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> url,
      Value<String?> favicon,
      Value<int?> parentFolderId,
      Value<bool> isFolder,
      Value<DateTime> createdAt,
      Value<int> sortOrder,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFolder => $composableBuilder(
    column: $table.isFolder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFolder => $composableBuilder(
    column: $table.isFolder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get favicon =>
      $composableBuilder(column: $table.favicon, builder: (column) => column);

  GeneratedColumn<int> get parentFolderId => $composableBuilder(
    column: $table.parentFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFolder =>
      $composableBuilder(column: $table.isFolder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
          Bookmark,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> favicon = const Value.absent(),
                Value<int?> parentFolderId = const Value.absent(),
                Value<bool> isFolder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                title: title,
                url: url,
                favicon: favicon,
                parentFolderId: parentFolderId,
                isFolder: isFolder,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                required String url,
                Value<String?> favicon = const Value.absent(),
                Value<int?> parentFolderId = const Value.absent(),
                Value<bool> isFolder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                title: title,
                url: url,
                favicon: favicon,
                parentFolderId: parentFolderId,
                isFolder: isFolder,
                createdAt: createdAt,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
      Bookmark,
      PrefetchHooks Function()
    >;
typedef $$HistoryEntriesTableCreateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> title,
      required String url,
      Value<String?> favicon,
      Value<DateTime> visitedAt,
      Value<int> visitCount,
    });
typedef $$HistoryEntriesTableUpdateCompanionBuilder =
    HistoryEntriesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> url,
      Value<String?> favicon,
      Value<DateTime> visitedAt,
      Value<int> visitCount,
    });

class $$HistoryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get favicon => $composableBuilder(
    column: $table.favicon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEntriesTable> {
  $$HistoryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get favicon =>
      $composableBuilder(column: $table.favicon, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  GeneratedColumn<int> get visitCount => $composableBuilder(
    column: $table.visitCount,
    builder: (column) => column,
  );
}

class $$HistoryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryEntriesTable,
          HistoryEntry,
          $$HistoryEntriesTableFilterComposer,
          $$HistoryEntriesTableOrderingComposer,
          $$HistoryEntriesTableAnnotationComposer,
          $$HistoryEntriesTableCreateCompanionBuilder,
          $$HistoryEntriesTableUpdateCompanionBuilder,
          (
            HistoryEntry,
            BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
          ),
          HistoryEntry,
          PrefetchHooks Function()
        > {
  $$HistoryEntriesTableTableManager(
    _$AppDatabase db,
    $HistoryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> favicon = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<int> visitCount = const Value.absent(),
              }) => HistoryEntriesCompanion(
                id: id,
                title: title,
                url: url,
                favicon: favicon,
                visitedAt: visitedAt,
                visitCount: visitCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                required String url,
                Value<String?> favicon = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<int> visitCount = const Value.absent(),
              }) => HistoryEntriesCompanion.insert(
                id: id,
                title: title,
                url: url,
                favicon: favicon,
                visitedAt: visitedAt,
                visitCount: visitCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryEntriesTable,
      HistoryEntry,
      $$HistoryEntriesTableFilterComposer,
      $$HistoryEntriesTableOrderingComposer,
      $$HistoryEntriesTableAnnotationComposer,
      $$HistoryEntriesTableCreateCompanionBuilder,
      $$HistoryEntriesTableUpdateCompanionBuilder,
      (
        HistoryEntry,
        BaseReferences<_$AppDatabase, $HistoryEntriesTable, HistoryEntry>,
      ),
      HistoryEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadsTableCreateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> id,
      required String url,
      required String fileName,
      required String filePath,
      Value<int> fileSize,
      Value<String?> mimeType,
      Value<int> status,
      Value<int> downloadedBytes,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });
typedef $$DownloadsTableUpdateCompanionBuilder =
    DownloadsCompanion Function({
      Value<int> id,
      Value<String> url,
      Value<String> fileName,
      Value<String> filePath,
      Value<int> fileSize,
      Value<String?> mimeType,
      Value<int> status,
      Value<int> downloadedBytes,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
    });

class $$DownloadsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadsTable> {
  $$DownloadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get downloadedBytes => $composableBuilder(
    column: $table.downloadedBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$DownloadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadsTable,
          Download,
          $$DownloadsTableFilterComposer,
          $$DownloadsTableOrderingComposer,
          $$DownloadsTableAnnotationComposer,
          $$DownloadsTableCreateCompanionBuilder,
          $$DownloadsTableUpdateCompanionBuilder,
          (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
          Download,
          PrefetchHooks Function()
        > {
  $$DownloadsTableTableManager(_$AppDatabase db, $DownloadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadsCompanion(
                id: id,
                url: url,
                fileName: fileName,
                filePath: filePath,
                fileSize: fileSize,
                mimeType: mimeType,
                status: status,
                downloadedBytes: downloadedBytes,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String fileName,
                required String filePath,
                Value<int> fileSize = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> downloadedBytes = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => DownloadsCompanion.insert(
                id: id,
                url: url,
                fileName: fileName,
                filePath: filePath,
                fileSize: fileSize,
                mimeType: mimeType,
                status: status,
                downloadedBytes: downloadedBytes,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadsTable,
      Download,
      $$DownloadsTableFilterComposer,
      $$DownloadsTableOrderingComposer,
      $$DownloadsTableAnnotationComposer,
      $$DownloadsTableCreateCompanionBuilder,
      $$DownloadsTableUpdateCompanionBuilder,
      (Download, BaseReferences<_$AppDatabase, $DownloadsTable, Download>),
      Download,
      PrefetchHooks Function()
    >;
typedef $$SitePermissionsTableCreateCompanionBuilder =
    SitePermissionsCompanion Function({
      Value<int> id,
      required String host,
      required String permission,
      Value<int> value,
      Value<DateTime> updatedAt,
    });
typedef $$SitePermissionsTableUpdateCompanionBuilder =
    SitePermissionsCompanion Function({
      Value<int> id,
      Value<String> host,
      Value<String> permission,
      Value<int> value,
      Value<DateTime> updatedAt,
    });

class $$SitePermissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SitePermissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SitePermissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SitePermissionsTable> {
  $$SitePermissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get permission => $composableBuilder(
    column: $table.permission,
    builder: (column) => column,
  );

  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SitePermissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SitePermissionsTable,
          SitePermission,
          $$SitePermissionsTableFilterComposer,
          $$SitePermissionsTableOrderingComposer,
          $$SitePermissionsTableAnnotationComposer,
          $$SitePermissionsTableCreateCompanionBuilder,
          $$SitePermissionsTableUpdateCompanionBuilder,
          (
            SitePermission,
            BaseReferences<
              _$AppDatabase,
              $SitePermissionsTable,
              SitePermission
            >,
          ),
          SitePermission,
          PrefetchHooks Function()
        > {
  $$SitePermissionsTableTableManager(
    _$AppDatabase db,
    $SitePermissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitePermissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitePermissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitePermissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<String> permission = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SitePermissionsCompanion(
                id: id,
                host: host,
                permission: permission,
                value: value,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String host,
                required String permission,
                Value<int> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SitePermissionsCompanion.insert(
                id: id,
                host: host,
                permission: permission,
                value: value,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SitePermissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SitePermissionsTable,
      SitePermission,
      $$SitePermissionsTableFilterComposer,
      $$SitePermissionsTableOrderingComposer,
      $$SitePermissionsTableAnnotationComposer,
      $$SitePermissionsTableCreateCompanionBuilder,
      $$SitePermissionsTableUpdateCompanionBuilder,
      (
        SitePermission,
        BaseReferences<_$AppDatabase, $SitePermissionsTable, SitePermission>,
      ),
      SitePermission,
      PrefetchHooks Function()
    >;
typedef $$BlockedRequestsTableCreateCompanionBuilder =
    BlockedRequestsCompanion Function({
      Value<int> id,
      required String pageUrl,
      required String blockedUrl,
      Value<String?> filterRule,
      Value<String> category,
      Value<DateTime> blockedAt,
    });
typedef $$BlockedRequestsTableUpdateCompanionBuilder =
    BlockedRequestsCompanion Function({
      Value<int> id,
      Value<String> pageUrl,
      Value<String> blockedUrl,
      Value<String?> filterRule,
      Value<String> category,
      Value<DateTime> blockedAt,
    });

class $$BlockedRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $BlockedRequestsTable> {
  $$BlockedRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedUrl => $composableBuilder(
    column: $table.blockedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterRule => $composableBuilder(
    column: $table.filterRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get blockedAt => $composableBuilder(
    column: $table.blockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BlockedRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $BlockedRequestsTable> {
  $$BlockedRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageUrl => $composableBuilder(
    column: $table.pageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedUrl => $composableBuilder(
    column: $table.blockedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterRule => $composableBuilder(
    column: $table.filterRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get blockedAt => $composableBuilder(
    column: $table.blockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BlockedRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BlockedRequestsTable> {
  $$BlockedRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pageUrl =>
      $composableBuilder(column: $table.pageUrl, builder: (column) => column);

  GeneratedColumn<String> get blockedUrl => $composableBuilder(
    column: $table.blockedUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filterRule => $composableBuilder(
    column: $table.filterRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<DateTime> get blockedAt =>
      $composableBuilder(column: $table.blockedAt, builder: (column) => column);
}

class $$BlockedRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BlockedRequestsTable,
          BlockedRequest,
          $$BlockedRequestsTableFilterComposer,
          $$BlockedRequestsTableOrderingComposer,
          $$BlockedRequestsTableAnnotationComposer,
          $$BlockedRequestsTableCreateCompanionBuilder,
          $$BlockedRequestsTableUpdateCompanionBuilder,
          (
            BlockedRequest,
            BaseReferences<
              _$AppDatabase,
              $BlockedRequestsTable,
              BlockedRequest
            >,
          ),
          BlockedRequest,
          PrefetchHooks Function()
        > {
  $$BlockedRequestsTableTableManager(
    _$AppDatabase db,
    $BlockedRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BlockedRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BlockedRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BlockedRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pageUrl = const Value.absent(),
                Value<String> blockedUrl = const Value.absent(),
                Value<String?> filterRule = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> blockedAt = const Value.absent(),
              }) => BlockedRequestsCompanion(
                id: id,
                pageUrl: pageUrl,
                blockedUrl: blockedUrl,
                filterRule: filterRule,
                category: category,
                blockedAt: blockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pageUrl,
                required String blockedUrl,
                Value<String?> filterRule = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<DateTime> blockedAt = const Value.absent(),
              }) => BlockedRequestsCompanion.insert(
                id: id,
                pageUrl: pageUrl,
                blockedUrl: blockedUrl,
                filterRule: filterRule,
                category: category,
                blockedAt: blockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BlockedRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BlockedRequestsTable,
      BlockedRequest,
      $$BlockedRequestsTableFilterComposer,
      $$BlockedRequestsTableOrderingComposer,
      $$BlockedRequestsTableAnnotationComposer,
      $$BlockedRequestsTableCreateCompanionBuilder,
      $$BlockedRequestsTableUpdateCompanionBuilder,
      (
        BlockedRequest,
        BaseReferences<_$AppDatabase, $BlockedRequestsTable, BlockedRequest>,
      ),
      BlockedRequest,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$HistoryEntriesTableTableManager get historyEntries =>
      $$HistoryEntriesTableTableManager(_db, _db.historyEntries);
  $$DownloadsTableTableManager get downloads =>
      $$DownloadsTableTableManager(_db, _db.downloads);
  $$SitePermissionsTableTableManager get sitePermissions =>
      $$SitePermissionsTableTableManager(_db, _db.sitePermissions);
  $$BlockedRequestsTableTableManager get blockedRequests =>
      $$BlockedRequestsTableTableManager(_db, _db.blockedRequests);
}
