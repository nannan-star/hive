import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/tables.dart';
import '../../shared/dates.dart';

part 'spend_entries_dao.g.dart';

@DriftAccessor(tables: [SpendEntries, Categories])
class SpendEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$SpendEntriesDaoMixin {
  SpendEntriesDao(super.db);

  static const _uuid = Uuid();

  Future<String> insertEntry({
    required String categoryId,
    required int amountCents,
    required String date,
    String? note,
    required String source,
    required String status,
  }) async {
    final id = _uuid.v4();
    await into(spendEntries).insert(
      SpendEntriesCompanion.insert(
        id: id,
        categoryId: categoryId,
        amountCents: amountCents,
        date: date,
        note: Value(note),
        source: source,
        status: status,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  Future<void> updateFields({
    required String id,
    required int amountCents,
    required String date,
    String? note,
  }) {
    return (update(spendEntries)..where((t) => t.id.equals(id))).write(
      SpendEntriesCompanion(
        amountCents: Value(amountCents),
        date: Value(date),
        note: Value(note),
      ),
    );
  }

  Future<void> setStatus(String id, String status) {
    return (update(spendEntries)..where((t) => t.id.equals(id))).write(
      SpendEntriesCompanion(status: Value(status)),
    );
  }

  Future<bool> hasTemplateSlot(String categoryId, int year, int month) async {
    final prefix = yearMonthPrefix(year, month);
    final rows = await (select(spendEntries)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.source.equals('template') &
                t.date.like('$prefix%') &
                (t.status.equals('pending') |
                    t.status.equals('confirmed') |
                    t.status.equals('skipped')),
          ))
        .get();
    return rows.isNotEmpty;
  }

  Stream<List<SpendEntry>> watchPendingForMonth(int year, int month) {
    final prefix = yearMonthPrefix(year, month);
    return (select(spendEntries)
          ..where(
            (t) =>
                t.status.equals('pending') & t.date.like('$prefix%'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Future<List<SpendEntry>> listConfirmedEntries(
    String categoryId,
    int year,
  ) {
    return (select(spendEntries)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.status.equals('confirmed') &
                t.date.like('$year-%'),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<SpendEntry?> getById(String id) {
    return (select(spendEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }
}
