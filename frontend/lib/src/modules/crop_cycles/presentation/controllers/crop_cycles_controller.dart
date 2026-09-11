import 'package:agrocampo_backend/agrocampo_backend.dart';

typedef CropsController = CropCyclesFacade;

final cropsControllerProvider = cropCyclesFacadeProvider;

/// The rotation surface is meaningful only for crop sectors. Keeping this
/// predicate in the presentation boundary prevents an apiary sector from
/// briefly exposing crop actions while its context is loading.
bool isRotationAvailableForSector(String? kind) =>
    ProductiveCategory.fromCode(kind) == ProductiveCategory.crop;

bool isRotationActivationDue(
  SectorCropAssignment assignment, {
  DateTime? now,
}) =>
    assignment.status == SectorCropAssignmentStatus.planned &&
    !(now ?? DateTime.now()).toUtc().isBefore(assignment.effectiveFrom.toUtc());

String rotationContextLabel(String? kind) =>
    isRotationAvailableForSector(kind) ? 'Sector vegetal' : 'Sector apícola';
