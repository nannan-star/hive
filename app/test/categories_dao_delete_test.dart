import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/daos/categories_dao.dart';
import 'package:hive_app/data/db/app_database.dart';

void main() {
  late AppDatabase db;
  late CategoriesDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = CategoriesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertCat(String id, String name) async {
    await db.into(db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name,
            sortOrder: 1,
            createdAt: 1000,
          ),
        );
  }

  Future<void> insertEntry({
    required String id,
    required String categoryId,
    required String status,
  }) async {
    await db.into(db.spendEntries).insert(
          SpendEntriesCompanion.insert(
            id: id,
            categoryId: categoryId,
            amountCents: 1000,
            date: '2026-09-01',
            source: 'manual',
            status: status,
            createdAt: 2000,
          ),
        );
  }

  test('countEntries is 0 when empty and counts all statuses', () async {
    await insertCat('c1', '电费');
    expect(await dao.countEntries('c1'), 0);

    await insertEntry(id: 'e1', categoryId: 'c1', status: 'pending');
    await insertEntry(id: 'e2', categoryId: 'c1', status: 'confirmed');
    await insertEntry(id: 'e3', categoryId: 'c1', status: 'skipped');
    expect(await dao.countEntries('c1'), 3);
  });

  test('deleteCategoryCascade removes category and its entries only', () async {
    await insertCat('c1', '电费');
    await insertCat('c2', '水费');
    await insertEntry(id: 'e1', categoryId: 'c1', status: 'confirmed');
    await insertEntry(id: 'e2', categoryId: 'c1', status: 'pending');
    await insertEntry(id: 'e3', categoryId: 'c2', status: 'confirmed');

    await dao.deleteCategoryCascade('c1');

    expect(await dao.getById('c1'), isNull);
    expect(await dao.getById('c2'), isNotNull);
    expect(await dao.countEntries('c1'), 0);
    expect(await dao.countEntries('c2'), 1);

    final left = await db.select(db.spendEntries).get();
    expect(left.map((e) => e.id), ['e3']);
  });

  test('deleteCategoryCascade works with zero entries', () async {
    await insertCat('c1', '旅行');
    await dao.deleteCategoryCascade('c1');
    expect(await dao.getById('c1'), isNull);
  });
}
