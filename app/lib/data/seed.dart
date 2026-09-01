import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'db/app_database.dart';

const _uuid = Uuid();

/// Inserts the seven default categories when the table is empty (idempotent).
Future<void> ensureSeedCategories(AppDatabase db) async {
  final count = await db.select(db.categories).get().then((rows) => rows.length);
  if (count > 0) return;

  final now = DateTime.now().millisecondsSinceEpoch;
  final seeds = <CategoriesCompanion>[
    _cat('停车费', 1, template: true, amount: 50000, now: now),
    _cat('水费', 2, template: true, amount: 5000, now: now),
    _cat('电费', 3, template: true, amount: 30000, now: now),
    _cat('燃气费', 4, template: true, amount: 8000, now: now),
    _cat('保险费', 5, template: false, now: now),
    _cat('旅行', 6, template: false, now: now),
    _cat('生活大额', 7, template: false, now: now),
  ];

  await db.batch((batch) {
    batch.insertAll(db.categories, seeds);
  });
}

CategoriesCompanion _cat(
  String name,
  int sort, {
  required bool template,
  int? amount,
  required int now,
}) {
  return CategoriesCompanion.insert(
    id: _uuid.v4(),
    name: name,
    sortOrder: sort,
    enabled: const Value(true),
    templateEnabled: Value(template),
    templateDefaultAmount: Value(amount),
    templateDay: const Value(1),
    createdAt: now,
  );
}
