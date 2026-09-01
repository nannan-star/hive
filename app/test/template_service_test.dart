import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/data/seed.dart';
import 'package:hive_app/features/spend/services/template_service.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('ensureMonthTemplates inserts pending template entries once', () async {
    await ensureSeedCategories(db);

    await TemplateService.ensureMonthTemplates(db, DateTime(2026, 8, 15));

    final pending = await db.spendEntriesDao.watchPendingForMonth(2026, 8).first;
    expect(pending, hasLength(4)); // parking/water/electric/gas
    final parking = pending.firstWhere(
      (e) => e.amountCents == 50000,
    );
    expect(parking.source, 'template');
    expect(parking.status, 'pending');
    expect(parking.date, '2026-08-01');

    await TemplateService.ensureMonthTemplates(db, DateTime(2026, 8, 20));
    final again = await db.spendEntriesDao.watchPendingForMonth(2026, 8).first;
    expect(again, hasLength(4));
  });

  test('skipped template slot blocks regeneration', () async {
    await ensureSeedCategories(db);
    await TemplateService.ensureMonthTemplates(db, DateTime(2026, 8, 15));

    final pending = await db.spendEntriesDao.watchPendingForMonth(2026, 8).first;
    await db.spendEntriesDao.setStatus(pending.first.id, 'skipped');

    await TemplateService.ensureMonthTemplates(db, DateTime(2026, 8, 16));
    final after = await (db.select(db.spendEntries)
          ..where((t) => t.source.equals('template')))
        .get();
    expect(after, hasLength(4));
  });
}
