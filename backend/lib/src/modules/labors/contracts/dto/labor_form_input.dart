import 'package:agrocampo_backend/src/modules/labors/domain/entities/labor_type.dart';
import 'package:agrocampo_backend/src/modules/agricultural_context/contracts/dto/save_outcome.dart';

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
    this.commandId,
  });
  final String sectorId;
  final LaborType type;
  final DateTime occurredAt;
  final String primary, secondary, amount, unit, extra, customName, notes;
  final CommandId? commandId;

  String get ownerIdempotencyKey =>
      '${sectorId.trim()}:${type.name}:${occurredAt.toUtc().toIso8601String()}:${primary.trim()}:${secondary.trim()}:${amount.trim()}:${unit.trim()}:${extra.trim()}:${customName.trim()}:${notes.trim()}';
}

enum LaborSaveStatus { saved, draftPreserved, noSession }
