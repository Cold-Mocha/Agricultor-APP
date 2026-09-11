import 'dart:convert';

import 'package:agrocampo_backend/src/composition/backend_providers.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/agricultural_context_api.dart';
import 'package:agrocampo_backend/src/modules/labors/contracts/dto/labor_form_input.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/cultivation_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/fertilization_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/irrigation_labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/other_labor_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/phytosanitary_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/pruning_details.dart';
import 'package:agrocampo_backend/src/modules/labors/domain/entities/sowing_details.dart';
import 'package:agrocampo_backend/src/modules/labors/infrastructure/persistence/labor_repository.dart';
import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final laborsFacadeProvider = Provider<LaborsFacade>(LaborsFacade.new);

final class LaborsFacade {
  LaborsFacade(this._ref);
  final Ref _ref;

  Future<LaborSaveStatus> save({
    required String ownerId,
    required LaborFormInput input,
  }) async {
    final outcome = await saveOutcome(ownerId: ownerId, input: input);
    return outcome is SavedLocal<LaborFormInput>
        ? LaborSaveStatus.saved
        : LaborSaveStatus.draftPreserved;
  }

  /// Typed command boundary used by independent backend callers. Every
  /// failure retains the exact input so a presentation layer can retry it;
  /// the legacy [save] method above remains source-compatible with 001/002.
  Future<SaveOutcome<LaborFormInput>> saveOutcome({
    required String ownerId,
    required LaborFormInput input,
  }) async {
    final database = _ref.read(appDatabaseProvider);
    final commandId =
        input.commandId ?? CommandId('labor:${input.ownerIdempotencyKey}');
    try {
      final sector =
          await (database.select(database.sectors)..where(
                (row) =>
                    row.ownerId.equals(ownerId) & row.id.equals(input.sectorId),
              ))
              .getSingle();
      await LaborRepository(database).save(
        ownerId: ownerId,
        parcelId: sector.parcelId,
        sectorId: sector.id,
        type: input.type,
        occurredAt: input.occurredAt.toUtc(),
        details: _details(input),
        customName: input.type == LaborType.other ? input.customName : null,
        notes: input.notes,
      );
      return SavedLocal(commandId: commandId, value: input);
    } on FormatException catch (error) {
      await _preserveDraft(database, ownerId, input);
      return ValidationFailed(
        commandId: commandId,
        fieldErrors: [
          FieldError(
            fieldId: _numericField(input),
            code: 'numeric_value_invalid',
            message: error.message,
          ),
        ],
        preservedInput: input,
      );
    } on StateError catch (error) {
      await _preserveDraft(database, ownerId, input);
      return DomainRejected(
        commandId: commandId,
        failure: DomainFailure(
          operation: 'labor.save',
          category: 'labor',
          code: error.message,
          message: error.message,
        ),
        preservedInput: input,
      );
    } on Object catch (error) {
      await _preserveDraft(database, ownerId, input);
      return StorageFailed(
        commandId: commandId,
        failure: StorageFailure(
          code: 'labor_save_failed',
          message: error.toString(),
        ),
        preservedInput: input,
      );
    }
  }

  String _numericField(LaborFormInput input) {
    if (input.type == LaborType.sowing ||
        input.type == LaborType.fertilization ||
        input.type == LaborType.diseaseAndPestControl) {
      return 'amount';
    }
    if (input.type == LaborType.cultivation) return 'primary';
    return 'amount';
  }

  Future<void> _preserveDraft(
    AppDatabase database,
    String ownerId,
    LaborFormInput input,
  ) => database.formDraftDao.save(
    ownerId,
    'labor',
    jsonEncode({
      'type': input.type.name,
      'primary': input.primary,
      'secondary': input.secondary,
      'amount': input.amount,
      'unit': input.unit,
      'extra': input.extra,
      'customName': input.customName,
      'notes': input.notes,
    }),
  );

  double _number(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) throw const FormatException('numeric_value_invalid');
    return parsed;
  }

  LaborDetails _details(LaborFormInput input) => switch (input.type) {
    LaborType.fertilization => FertilizationDetails(
      product: input.primary,
      amount: _number(input.amount),
      unit: input.unit,
      applicationMethod: input.secondary,
      observations: input.notes,
    ).toEnvelope(),
    LaborType.diseaseAndPestControl => PhytosanitaryDetails(
      product: input.primary,
      target: input.secondary,
      dose: _number(input.amount),
      unit: input.unit,
      safetyIntervalDays: int.tryParse(input.extra.trim()),
      observations: input.notes,
    ).toEnvelope(),
    LaborType.cultivation => CultivationDetails(
      performedWork: input.primary,
      observedState: input.secondary,
      variety: input.extra.trim().isEmpty ? null : input.extra,
      observations: input.notes,
    ).toEnvelope(),
    LaborType.sowing => SowingDetails(
      seedQuantity: _number(input.amount),
      unit: input.unit,
      spacingCentimeters: input.extra.trim().isEmpty
          ? null
          : _number(input.extra),
    ).toEnvelope(),
    LaborType.pruning => PruningDetails(
      method: input.primary,
      plantCount: input.amount.trim().isEmpty
          ? null
          : int.tryParse(input.amount.trim()),
    ).toEnvelope(),
    LaborType.other => OtherLaborDetails(
      name: input.customName,
      description: input.primary,
    ).toEnvelope(),
    LaborType.irrigation => IrrigationLaborDetails(
      method: input.primary,
      durationMinutes: int.tryParse(input.amount.trim()) ?? 0,
      appliedVolumeLiters: input.extra.trim().isEmpty
          ? null
          : _number(input.extra),
    ).toEnvelope(),
    LaborType.soil ||
    LaborType.apiary => LaborDetails.current(input.type, const {}),
    LaborType.harvest => throw StateError('harvest_uses_production_flow'),
  };
}
