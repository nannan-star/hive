import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../daos/categories_dao.dart';
import '../daos/dream_dao.dart';
import '../daos/spend_entries_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Categories, SpendEntries, DreamJars, DreamDeposits],
  daos: [CategoriesDao, SpendEntriesDao, DreamDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'hive',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
