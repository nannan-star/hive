import 'dart:convert';

import '../../../data/db/app_database.dart';

enum BackupErrorCode {
  unreadable,
  notHive,
  unsupportedFormat,
  schemaMismatch,
  invalidPayload,
  brokenReferences,
  io,
}

class BackupException implements Exception {
  BackupException(this.code, [this.message]);

  final BackupErrorCode code;
  final String? message;

  @override
  String toString() =>
      'BackupException($code${message == null ? '' : ': $message'})';
}

class BackupPayload {
  const BackupPayload({
    required this.exportedAt,
    required this.categories,
    required this.spendEntries,
    required this.dreamJars,
    required this.dreamDeposits,
  });

  final DateTime exportedAt;
  final List<Category> categories;
  final List<SpendEntry> spendEntries;
  final List<DreamJar> dreamJars;
  final List<DreamDeposit> dreamDeposits;
}

class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  static const formatVersion = 1;

  Future<String> exportJson() async {
    return db.transaction(() async {
      final categories = await db.select(db.categories).get();
      final spendEntries = await db.select(db.spendEntries).get();
      final dreamJars = await db.select(db.dreamJars).get();
      final dreamDeposits = await db.select(db.dreamDeposits).get();
      return jsonEncode({
        'app': 'hive',
        'formatVersion': formatVersion,
        'schemaVersion': db.schemaVersion,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'categories': categories.map((r) => r.toJson()).toList(),
        'spendEntries': spendEntries.map((r) => r.toJson()).toList(),
        'dreamJars': dreamJars.map((r) => r.toJson()).toList(),
        'dreamDeposits': dreamDeposits.map((r) => r.toJson()).toList(),
      });
    });
  }

  BackupPayload parse(String source) {
    late final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw BackupException(BackupErrorCode.unreadable);
    }
    if (decoded is! Map) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    final map = Map<String, dynamic>.from(decoded);

    if (!map.containsKey('app')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['app'] is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['app'] != 'hive') {
      throw BackupException(BackupErrorCode.notHive);
    }
    if (!map.containsKey('formatVersion')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['formatVersion'] is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['formatVersion'] != formatVersion) {
      throw BackupException(BackupErrorCode.unsupportedFormat);
    }
    if (!map.containsKey('schemaVersion')) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['schemaVersion'] is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    if (map['schemaVersion'] != db.schemaVersion) {
      throw BackupException(BackupErrorCode.schemaMismatch);
    }

    final exportedAtRaw = map['exportedAt'];
    if (exportedAtRaw is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }

    final categories = _parseCategories(_asMaps(map['categories']));
    final spendEntries = _parseSpends(_asMaps(map['spendEntries']));
    final dreamJars = _parseJars(_asMaps(map['dreamJars']));
    final dreamDeposits = _parseDeposits(_asMaps(map['dreamDeposits']));

    _assertUnique(categories.map((e) => e.id));
    _assertUnique(spendEntries.map((e) => e.id));
    _assertUnique(dreamJars.map((e) => e.id));
    _assertUnique(dreamDeposits.map((e) => e.id));

    final catIds = categories.map((e) => e.id).toSet();
    final jarIds = dreamJars.map((e) => e.id).toSet();
    for (final row in spendEntries) {
      if (!catIds.contains(row.categoryId)) {
        throw BackupException(BackupErrorCode.brokenReferences);
      }
    }
    for (final row in dreamDeposits) {
      if (!jarIds.contains(row.jarId)) {
        throw BackupException(BackupErrorCode.brokenReferences);
      }
    }

    return BackupPayload(
      exportedAt: exportedAt,
      categories: categories,
      spendEntries: spendEntries,
      dreamJars: dreamJars,
      dreamDeposits: dreamDeposits,
    );
  }

  Future<void> restore(BackupPayload payload) {
    return db.transaction(() async {
      await db.delete(db.dreamDeposits).go();
      await db.delete(db.spendEntries).go();
      await db.delete(db.dreamJars).go();
      await db.delete(db.categories).go();
      await db.batch((b) {
        b.insertAll(db.categories, payload.categories);
        b.insertAll(db.dreamJars, payload.dreamJars);
        b.insertAll(db.spendEntries, payload.spendEntries);
        b.insertAll(db.dreamDeposits, payload.dreamDeposits);
      });
    });
  }

  List<Map<String, dynamic>> _asMaps(dynamic raw) {
    if (raw is! List) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return [
      for (final item in raw)
        if (item is Map)
          Map<String, dynamic>.from(item)
        else
          throw BackupException(BackupErrorCode.invalidPayload),
    ];
  }

  void _assertUnique(Iterable<String> ids) {
    final seen = <String>{};
    for (final id in ids) {
      if (!seen.add(id)) {
        throw BackupException(BackupErrorCode.invalidPayload);
      }
    }
  }

  List<Category> _parseCategories(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        Category(
          id: _reqString(r, 'id'),
          name: _reqString(r, 'name'),
          sortOrder: _reqInt(r, 'sortOrder'),
          enabled: _reqBool(r, 'enabled'),
          note: _optString(r, 'note'),
          templateEnabled: _reqBool(r, 'templateEnabled'),
          templateDefaultAmount: _optInt(r, 'templateDefaultAmount'),
          templateDefaultNote: _optString(r, 'templateDefaultNote'),
          templateDay: _reqInt(r, 'templateDay'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<SpendEntry> _parseSpends(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        SpendEntry(
          id: _reqString(r, 'id'),
          categoryId: _reqString(r, 'categoryId'),
          amountCents: _reqInt(r, 'amountCents'),
          date: _reqString(r, 'date'),
          note: _optString(r, 'note'),
          source: _reqString(r, 'source'),
          status: _reqString(r, 'status'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<DreamJar> _parseJars(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        DreamJar(
          id: _reqString(r, 'id'),
          name: _reqString(r, 'name'),
          targetCents: _reqInt(r, 'targetCents'),
          kind: _optString(r, 'kind') ?? 'goal',
          status: _reqString(r, 'status'),
          description: _optString(r, 'description'),
          familyId: _optString(r, 'familyId'),
          memberId: _optString(r, 'memberId'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  List<DreamDeposit> _parseDeposits(List<Map<String, dynamic>> rows) {
    return [
      for (final r in rows)
        DreamDeposit(
          id: _reqString(r, 'id'),
          jarId: _reqString(r, 'jarId'),
          amountCents: _reqInt(r, 'amountCents'),
          date: _reqString(r, 'date'),
          note: _optString(r, 'note'),
          createdAt: _reqInt(r, 'createdAt'),
        ),
    ];
  }

  String _reqString(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  String? _optString(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v == null) return null;
    if (v is! String) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  int _reqInt(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  int? _optInt(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v == null) return null;
    if (v is! int) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }

  bool _reqBool(Map<String, dynamic> r, String key) {
    final v = r[key];
    if (v is! bool) {
      throw BackupException(BackupErrorCode.invalidPayload);
    }
    return v;
  }
}
