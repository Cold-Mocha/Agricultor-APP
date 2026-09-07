import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/backend_providers.dart';
import '../../auth/controllers/session_controller.dart';
import '../domain/fertilization_details.dart';
import '../domain/irrigation_labor_details.dart';
import '../domain/labor_details.dart';
import '../domain/labor_type.dart';
import '../domain/other_labor_details.dart';
import '../domain/phytosanitary_details.dart';
import '../domain/pruning_details.dart';
import '../domain/sowing_details.dart';
import '../dto/labor_form_input.dart';
import '../repositories/labor_repository.dart';

final laborFormControllerProvider = Provider<LaborFormController>(
  LaborFormController.new,
);

final class LaborFormController {
  LaborFormController(this._ref);
  final Ref _ref;

  Future<LaborSaveStatus> save(LaborFormInput input) async {
    final ownerId = _ref.read(unlockedOwnerIdProvider);
    if (ownerId == null) return LaborSaveStatus.noSession;
    final database = _ref.read(appDatabaseProvider);
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
      return LaborSaveStatus.saved;
    } on Object {
      await database.formDraftDao.save(
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
      return LaborSaveStatus.draftPreserved;
    }
  }

  double _number(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;

  LaborDetails _details(LaborFormInput input) => switch (input.type) {
    LaborType.fertilization => FertilizationDetails(
      product: input.primary,
      amount: _number(input.amount),
      unit: input.unit,
      applicationMethod: input.secondary,
    ).toEnvelope(),
    LaborType.diseaseAndPestControl => PhytosanitaryDetails(
      product: input.primary,
      target: input.secondary,
      dose: _number(input.amount),
      unit: input.unit,
      safetyIntervalDays: int.tryParse(input.extra.trim()),
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
