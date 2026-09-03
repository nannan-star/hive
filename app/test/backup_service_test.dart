import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/features/settings/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedSample(AppDatabase target) async {
    await target
        .into(target.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat-1',
            name: '停车费',
            sortOrder: 1,
            enabled: const Value(true),
            templateEnabled: const Value(true),
            templateDefaultAmount: const Value(50000),
            createdAt: 1000,
          ),
        );
    await target
        .into(target.spendEntries)
        .insert(
          SpendEntriesCompanion.insert(
            id: 'sp-1',
            categoryId: 'cat-1',
            amountCents: 50000,
            date: '2026-09-01',
            source: 'manual',
            status: 'confirmed',
            createdAt: 2000,
          ),
        );
    await target
        .into(target.dreamJars)
        .insert(
          DreamJarsCompanion.insert(
            id: 'jar-1',
            name: '旅行',
            targetCents: 100000,
            status: 'active',
            createdAt: 3000,
          ),
        );
    await target
        .into(target.dreamDeposits)
        .insert(
          DreamDepositsCompanion.insert(
            id: 'dep-1',
            jarId: 'jar-1',
            amountCents: 10000,
            date: '2026-09-01',
            createdAt: 4000,
          ),
        );
  }

  List<T> sortedById<T>(List<T> rows, String Function(T) idOf) {
    return [...rows]..sort((a, b) => idOf(a).compareTo(idOf(b)));
  }

  test('export then restore into empty db keeps all fields', () async {
    await seedSample(db);

    final sourceCats = await db.select(db.categories).get();
    final sourceSpends = await db.select(db.spendEntries).get();
    final sourceJars = await db.select(db.dreamJars).get();
    final sourceDeps = await db.select(db.dreamDeposits).get();

    final json = await backup.exportJson();
    final payload = backup.parse(json);
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    expect(decoded['app'], 'hive');
    expect(decoded['formatVersion'], 1);
    expect(decoded['schemaVersion'], 2);
    expect(decoded['exportedAt'], isA<String>());
    expect(decoded['exportedAt'], endsWith('Z'));
    expect(decoded['categories'][0]['note'], isNull);

    final empty = AppDatabase(NativeDatabase.memory());
    addTearDown(empty.close);
    await BackupService(empty).restore(payload);

    expect(
      sortedById(await empty.select(empty.categories).get(), (r) => r.id),
      sortedById(sourceCats, (r) => r.id),
    );
    expect(
      sortedById(await empty.select(empty.spendEntries).get(), (r) => r.id),
      sortedById(sourceSpends, (r) => r.id),
    );
    expect(
      sortedById(await empty.select(empty.dreamJars).get(), (r) => r.id),
      sortedById(sourceJars, (r) => r.id),
    );
    expect(
      sortedById(await empty.select(empty.dreamDeposits).get(), (r) => r.id),
      sortedById(sourceDeps, (r) => r.id),
    );
  });

  test('restore replaces existing rows', () async {
    await seedSample(db);
    final payload = backup.parse(await backup.exportJson());

    final other = AppDatabase(NativeDatabase.memory());
    addTearDown(other.close);
    await other
        .into(other.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'old-cat',
            name: '旧分类',
            sortOrder: 9,
            createdAt: 1,
          ),
        );

    await BackupService(other).restore(payload);

    final cats = await other.select(other.categories).get();
    expect(cats, hasLength(1));
    expect(cats.single.id, 'cat-1');
    expect(await other.select(other.spendEntries).get(), hasLength(1));
  });

  test('parse rejects bad files with expected codes', () {
    expect(
      () => backup.parse('not-json'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.unreadable,
        ),
      ),
    );
    expect(
      () => backup.parse(
        '{"app":"other","formatVersion":1,"schemaVersion":1,'
        '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
        '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}',
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.notHive,
        ),
      ),
    );
    expect(
      () => backup.parse(
        '{"app":"hive","formatVersion":2,"schemaVersion":1,'
        '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
        '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}',
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.unsupportedFormat,
        ),
      ),
    );
    expect(
      () => backup.parse(
        '{"app":"hive","formatVersion":1,"schemaVersion":99,'
        '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
        '"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}',
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.schemaMismatch,
        ),
      ),
    );
    expect(
      () => backup.parse(
        '{"app":"hive","formatVersion":1,"schemaVersion":2,'
        '"exportedAt":"2026-09-01T00:00:00.000Z","categories":[],'
        '"spendEntries":[{"id":"sp-1","categoryId":"missing","amountCents":1,'
        '"date":"2026-09-01","source":"manual","status":"confirmed",'
        '"createdAt":1}],"dreamJars":[],"dreamDeposits":[]}',
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.brokenReferences,
        ),
      ),
    );
    expect(
      () => backup.parse(
        '{"app":"hive","formatVersion":1,"schemaVersion":2,'
        '"exportedAt":"2026-09-01T00:00:00.000Z","categories":['
        '{"id":"a","name":"x","sortOrder":1,"enabled":true,'
        '"templateEnabled":false,"templateDay":1,"createdAt":1},'
        '{"id":"a","name":"y","sortOrder":2,"enabled":true,'
        '"templateEnabled":false,"templateDay":1,"createdAt":2}'
        '],"spendEntries":[],"dreamJars":[],"dreamDeposits":[]}',
      ),
      throwsA(
        isA<BackupException>().having(
          (e) => e.code,
          'code',
          BackupErrorCode.invalidPayload,
        ),
      ),
    );
  });
}
