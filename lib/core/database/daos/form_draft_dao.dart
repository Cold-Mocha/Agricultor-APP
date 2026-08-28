import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/database/tables/technical_tables.dart';
import 'package:drift/drift.dart';

part 'form_draft_dao.g.dart';

@DriftAccessor(tables: [FormDrafts])
class FormDraftDao extends DatabaseAccessor<AppDatabase>
    with _$FormDraftDaoMixin {
  FormDraftDao(super.attachedDatabase);

  Future<void> save(String ownerId, String key, String payloadJson) =>
      into(formDrafts).insertOnConflictUpdate(
        FormDraftsCompanion.insert(
          ownerId: ownerId,
          draftKey: key,
          payloadJson: payloadJson,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

  Future<String?> read(String ownerId, String key) async =>
      (await (select(formDrafts)..where(
                (row) => row.ownerId.equals(ownerId) & row.draftKey.equals(key),
              ))
              .getSingleOrNull())
          ?.payloadJson;

  Future<void> clear(String ownerId, String key) =>
      (delete(formDrafts)..where(
            (row) => row.ownerId.equals(ownerId) & row.draftKey.equals(key),
          ))
          .go();
}
