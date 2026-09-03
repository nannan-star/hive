import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'dream_dao.g.dart';

@DriftAccessor(tables: [DreamJars, DreamDeposits])
class DreamDao extends DatabaseAccessor<AppDatabase> with _$DreamDaoMixin {
  DreamDao(super.db);

  static const _uuid = Uuid();

  Stream<List<DreamJar>> watchJars({required bool includeCompleted}) {
    final q = select(dreamJars);
    if (!includeCompleted) {
      q.where((t) => t.status.equals('active'));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch();
  }

  Future<DreamJar?> getJar(String id) {
    return (select(dreamJars)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<String> insertJar({
    required String name,
    required int targetCents,
    String? description,
  }) async {
    final id = _uuid.v4();
    await into(dreamJars).insert(
      DreamJarsCompanion.insert(
        id: id,
        name: name,
        targetCents: targetCents,
        kind: 'goal',
        status: 'active',
        description: Value(description),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  Future<String> insertFund({
    required String name,
    String? description,
  }) async {
    final id = _uuid.v4();
    await into(dreamJars).insert(
      DreamJarsCompanion.insert(
        id: id,
        name: name,
        targetCents: 0,
        kind: 'fund',
        status: 'active',
        description: Value(description),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  Future<void> updateJar({
    required String id,
    required String name,
    required int targetCents,
    String? description,
  }) {
    return (update(dreamJars)..where((t) => t.id.equals(id))).write(
      DreamJarsCompanion(
        name: Value(name),
        targetCents: Value(targetCents),
        description: Value(description),
      ),
    );
  }

  Future<void> markCompleted(String id) {
    return (update(dreamJars)..where((t) => t.id.equals(id))).write(
      const DreamJarsCompanion(status: Value('completed')),
    );
  }

  Stream<List<DreamDeposit>> watchDeposits(String jarId) {
    return (select(dreamDeposits)
          ..where((t) => t.jarId.equals(jarId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<int> sumDeposits(String jarId) async {
    final rows = await (select(dreamDeposits)
          ..where((t) => t.jarId.equals(jarId)))
        .get();
    return rows.fold<int>(0, (a, b) => a + b.amountCents);
  }

  Future<String> insertDeposit({
    required String jarId,
    required int amountCents,
    required String date,
    String? note,
  }) async {
    final id = _uuid.v4();
    await into(dreamDeposits).insert(
      DreamDepositsCompanion.insert(
        id: id,
        jarId: jarId,
        amountCents: amountCents,
        date: date,
        note: Value(note),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  Future<void> updateDeposit({
    required String id,
    required int amountCents,
    required String date,
    String? note,
  }) {
    return (update(dreamDeposits)..where((t) => t.id.equals(id))).write(
      DreamDepositsCompanion(
        amountCents: Value(amountCents),
        date: Value(date),
        note: Value(note),
      ),
    );
  }

  Future<void> deleteDeposit(String id) {
    return (delete(dreamDeposits)..where((t) => t.id.equals(id))).go();
  }
}
