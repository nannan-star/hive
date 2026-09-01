import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/data/seed.dart';
import 'package:hive_app/features/spend/services/spend_stats_service.dart';

void main() {
  late AppDatabase db;
  late SpendStatsService stats;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    stats = SpendStatsService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('sums confirmed only and computes YoY', () async {
    await ensureSeedCategories(db);
    final parking =
        (await db.select(db.categories).get()).firstWhere((c) => c.name == '停车费');

    await db.spendEntriesDao.insertEntry(
      categoryId: parking.id,
      amountCents: 50000,
      date: '2026-03-01',
      source: 'manual',
      status: 'confirmed',
    );
    await db.spendEntriesDao.insertEntry(
      categoryId: parking.id,
      amountCents: 40000,
      date: '2025-03-01',
      source: 'manual',
      status: 'confirmed',
    );
    await db.spendEntriesDao.insertEntry(
      categoryId: parking.id,
      amountCents: 9999,
      date: '2026-04-01',
      source: 'template',
      status: 'pending',
    );

    final byCat = await stats.sumByCategory(2026);
    expect(byCat[parking.id], 50000);

    final yoy = await stats.yoy(parking.id, 2026);
    expect(yoy.thisYear, 50000);
    expect(yoy.lastYear, 40000);
    expect(yoy.delta, 10000);
    expect(yoy.percent, closeTo(25.0, 0.01));

    expect(await stats.yearTotal(2026), 50000);

    final entries = await stats.listConfirmedEntries(parking.id, 2026);
    expect(entries, hasLength(1));
  });
}
