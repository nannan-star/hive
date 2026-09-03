import '../../../data/db/app_database.dart';

class DreamService {
  DreamService(this.db);

  final AppDatabase db;

  Future<int> savedCents(String jarId) => db.dreamDao.sumDeposits(jarId);

  Future<void> complete(String jarId) async {
    final jar = await db.dreamDao.getJar(jarId);
    if (jar == null) throw StateError('jar not found');
    if (jar.kind != 'goal') throw StateError('complete only for goal');
    await db.dreamDao.markCompleted(jarId);
  }

  Future<String> createFund({required String name, String? description}) =>
      db.dreamDao.insertFund(name: name, description: description);

  Future<int> balanceCents(String jarId) => db.dreamDao.sumDeposits(jarId);

  Future<void> deposit({
    required String jarId,
    required int amountCents,
    required String date,
    String? note,
  }) async {
    if (amountCents <= 0) throw StateError('amount must be positive');
    final jar = await db.dreamDao.getJar(jarId);
    if (jar == null) throw StateError('jar not found');
    await db.dreamDao.insertDeposit(
      jarId: jarId,
      amountCents: amountCents,
      date: date,
      note: note,
    );
  }

  Future<void> withdraw({
    required String jarId,
    required int amountCents,
    required String date,
    String? note,
  }) async {
    if (amountCents <= 0) throw StateError('amount must be positive');
    final jar = await db.dreamDao.getJar(jarId);
    if (jar == null) throw StateError('jar not found');
    if (jar.kind != 'fund') throw StateError('withdraw only for fund');
    final bal = await balanceCents(jarId);
    if (amountCents > bal) throw StateError('insufficient balance');
    await db.dreamDao.insertDeposit(
      jarId: jarId,
      amountCents: -amountCents,
      date: date,
      note: note,
    );
  }

  Future<void> deleteFund(String jarId, {required bool confirmNonZero}) async {
    final jar = await db.dreamDao.getJar(jarId);
    if (jar == null || jar.kind != 'fund') throw StateError('not a fund');
    final bal = await balanceCents(jarId);
    if (bal != 0 && !confirmNonZero) throw StateError('balance not zero');
    await db.dreamDao.deleteJar(jarId);
  }

  Future<void> renameFund({required String id, required String name}) async {
    final jar = await db.dreamDao.getJar(id);
    if (jar == null || jar.kind != 'fund') throw StateError('not a fund');
    await db.dreamDao.renameFund(id: id, name: name);
  }
}
