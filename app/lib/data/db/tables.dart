import 'package:drift/drift.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  BoolColumn get templateEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get templateDefaultAmount => integer().nullable()();
  TextColumn get templateDefaultNote => text().nullable()();
  IntColumn get templateDay => integer().withDefault(const Constant(1))();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SpendEntries extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().references(Categories, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get note => text().nullable()();
  TextColumn get source => text()(); // template | manual
  TextColumn get status => text()(); // pending | confirmed | skipped
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DreamJars extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetCents => integer()();
  TextColumn get status => text()(); // active | completed
  TextColumn get description => text().nullable()();
  TextColumn get familyId => text().nullable()();
  TextColumn get memberId => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class DreamDeposits extends Table {
  TextColumn get id => text()();
  TextColumn get jarId => text().references(DreamJars, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
