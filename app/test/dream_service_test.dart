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

  test('fund deposit withdraw balance and reject overdraft', () async {
    final id = await service.createFund(name: '备用金');
    await service.deposit(jarId: id, amountCents: 10000, date: '2026-09-01');
    await service.withdraw(jarId: id, amountCents: 3000, date: '2026-09-02');
    expect(await service.balanceCents(id), 7000);

    await expectLater(
      service.withdraw(jarId: id, amountCents: 8000, date: '2026-09-03'),
      throwsA(isA<StateError>()),
    );
    expect(await service.balanceCents(id), 7000);

    final spends = await db.select(db.spendEntries).get();
    expect(spends, isEmpty);
  });

  test('goal rejects withdraw', () async {
    final id = await db.dreamDao.insertJar(name: '滑雪', targetCents: 100000);
    await expectLater(
      service.withdraw(jarId: id, amountCents: 100, date: '2026-09-01'),
      throwsA(isA<StateError>()),
    );
  });
}
