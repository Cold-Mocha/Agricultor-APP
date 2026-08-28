// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conflict_dao.dart';

// ignore_for_file: type=lint
mixin _$ConflictDaoMixin on DatabaseAccessor<AppDatabase> {
  $SyncConflictsTable get syncConflicts => attachedDatabase.syncConflicts;
  ConflictDaoManager get managers => ConflictDaoManager(this);
}

class ConflictDaoManager {
  final _$ConflictDaoMixin _db;
  ConflictDaoManager(this._db);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db.attachedDatabase, _db.syncConflicts);
}
