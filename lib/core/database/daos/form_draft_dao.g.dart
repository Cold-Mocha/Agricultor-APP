// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_draft_dao.dart';

// ignore_for_file: type=lint
mixin _$FormDraftDaoMixin on DatabaseAccessor<AppDatabase> {
  $FormDraftsTable get formDrafts => attachedDatabase.formDrafts;
  FormDraftDaoManager get managers => FormDraftDaoManager(this);
}

class FormDraftDaoManager {
  final _$FormDraftDaoMixin _db;
  FormDraftDaoManager(this._db);
  $$FormDraftsTableTableManager get formDrafts =>
      $$FormDraftsTableTableManager(_db.attachedDatabase, _db.formDrafts);
}
