// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dream_dao.dart';

// ignore_for_file: type=lint
mixin _$DreamDaoMixin on DatabaseAccessor<AppDatabase> {
  $DreamJarsTable get dreamJars => attachedDatabase.dreamJars;
  $DreamDepositsTable get dreamDeposits => attachedDatabase.dreamDeposits;
  DreamDaoManager get managers => DreamDaoManager(this);
}

class DreamDaoManager {
  final _$DreamDaoMixin _db;
  DreamDaoManager(this._db);
  $$DreamJarsTableTableManager get dreamJars =>
      $$DreamJarsTableTableManager(_db.attachedDatabase, _db.dreamJars);
  $$DreamDepositsTableTableManager get dreamDeposits =>
      $$DreamDepositsTableTableManager(_db.attachedDatabase, _db.dreamDeposits);
}
