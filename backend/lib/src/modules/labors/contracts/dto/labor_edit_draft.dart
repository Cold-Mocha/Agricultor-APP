import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';

/// Prefilled text for [LaborFormInput]'s generic fields, reverse-mapped from
/// an existing labor's typed details so the form can reopen it for
/// correction without each labor type leaking its JSON shape into the UI.
final class LaborEditDraft {
  const LaborEditDraft({
    required this.sectorId,
    required this.type,
    required this.occurredAt,
    required this.primary,
    required this.secondary,
    required this.amount,
    required this.unit,
    required this.extra,
    required this.customName,
    required this.notes,
  });

  final String sectorId;
  final LaborType type;
  final DateTime occurredAt;
  final String primary, secondary, amount, unit, extra, customName, notes;
}
