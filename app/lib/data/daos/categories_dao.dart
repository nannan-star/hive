import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [Categories, SpendEntries])
class CategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  static const _uuid = Uuid();

  Stream<List<Category>> watchEnabled() {
    return (select(categories)
          ..where((t) => t.enabled.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Stream<List<Category>> watchAll() {
    return (select(categories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch();
  }

  Future<Category?> getById(String id) {
    return (select(categories)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> insertCategory({
    required String name,
    required int sortOrder,
    required bool enabled,
    required bool templateEnabled,
    int? templateDefaultAmount,
    String? templateDefaultNote,
    int templateDay = 1,
    String? note,
  }) async {
    final id = _uuid.v4();
    await into(categories).insert(
      CategoriesCompanion.insert(
        id: id,
        name: name,
        sortOrder: sortOrder,
        enabled: Value(enabled),
        note: Value(note),
        templateEnabled: Value(templateEnabled),
        templateDefaultAmount: Value(templateDefaultAmount),
        templateDefaultNote: Value(templateDefaultNote),
        templateDay: Value(templateDay),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    return id;
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required int sortOrder,
    required bool enabled,
    required bool templateEnabled,
    int? templateDefaultAmount,
    String? templateDefaultNote,
    int templateDay = 1,
    String? note,
  }) {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name),
        sortOrder: Value(sortOrder),
        enabled: Value(enabled),
        note: Value(note),
        templateEnabled: Value(templateEnabled),
        templateDefaultAmount: Value(templateDefaultAmount),
        templateDefaultNote: Value(templateDefaultNote),
        templateDay: Value(templateDay),
      ),
    );
  }

  Future<void> setEnabled(String id, bool enabled) {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(enabled: Value(enabled)),
    );
  }

  Future<int> countEntries(String categoryId) async {
    final count = countAll();
    final query = selectOnly(spendEntries)
      ..addColumns([count])
      ..where(spendEntries.categoryId.equals(categoryId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> deleteCategoryCascade(String categoryId) {
    return transaction(() async {
      await (delete(spendEntries)
            ..where((t) => t.categoryId.equals(categoryId)))
          .go();
      await (delete(categories)..where((t) => t.id.equals(categoryId))).go();
    });
  }
}
