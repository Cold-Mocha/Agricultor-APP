import '../domain/labor_type.dart';

/// Text entered by the form, retained unchanged when a draft is needed.
final class LaborFormInput {
  const LaborFormInput({
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

enum LaborSaveStatus { saved, draftPreserved, noSession }
