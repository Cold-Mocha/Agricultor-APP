import 'package:agrocampo_backend/src/modules/irrigation/domain/entities/irrigation_record.dart';

final class IrrigationFormInput {
  const IrrigationFormInput({
    required this.sectorId,
    required this.type,
    required this.soilType,
    required this.duration,
    required this.flow,
    this.pressure,
  });
  final String? sectorId;
  final IrrigationType type;
  final SoilType soilType;
  final String duration, flow;
  final String? pressure;
}
