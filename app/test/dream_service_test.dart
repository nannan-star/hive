import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_app/data/db/app_database.dart';
import 'package:hive_app/features/dream/services/dream_service.dart';

void main() {
  late AppDatabase db;
  late DreamService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    service = DreamService(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('deposits sum and complete without spend entries', () async {
    final id = await db.dreamDao.insertJar(
      name: '换车',
      targetCents: 2000000,
    );
    await db.dreamDao.insertDeposit(
      jarId: id,
      amountCents: 500000,
      date: '2026-01-01',
    );
    await db.dreamDao.insertDeposit(
      jarId: id,
      amountCents: 300000,
      date: '2026-02-01',
    );

    expect(await service.savedCents(id), 800000);
    await service.complete(id);
    final jar = await db.dreamDao.getJar(id);
    expect(jar!.status, 'completed');

    final spends = await db.select(db.spendEntries).get();
    expect(spends, isEmpty);
  });
}
