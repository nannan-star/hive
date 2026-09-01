// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spend_entries_dao.dart';

// ignore_for_file: type=lint
mixin _$SpendEntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SpendEntriesTable get spendEntries => attachedDatabase.spendEntries;
  $CategoriesTable get categories => attachedDatabase.categories;
  SpendEntriesDaoManager get managers => SpendEntriesDaoManager(this);
}

class SpendEntriesDaoManager {
  final _$SpendEntriesDaoMixin _db;
  SpendEntriesDaoManager(this._db);
  $$SpendEntriesTableTableManager get spendEntries =>
      $$SpendEntriesTableTableManager(_db.attachedDatabase, _db.spendEntries);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}
