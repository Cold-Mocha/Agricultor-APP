import 'package:agrocampo_backend/src/shared/contracts/productive_domain.dart';

final class ContextLabels {
  const ContextLabels({
    this.parcel,
    this.sector,
    this.category,
    this.season,
    this.crop,
  });

  final String? parcel;
  final String? sector;
  final String? category;
  final String? season;
  final String? crop;
}

final class AgriculturalContext {
  const AgriculturalContext({
    this.ownerId,
    this.parcelId,
    this.sectorId,
    this.seasonId,
    this.assignmentId,
    this.revision = 0,
    this.isRestoring = false,
    this.category,
    this.labels = const ContextLabels(),
    this.allowedOperations = const <ProductiveOperation>[],
    this.resolvedFor,
  });

  const AgriculturalContext.restoring(String ownerId)
    : this(ownerId: ownerId, isRestoring: true);

  final String? ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
  final String? assignmentId;
  final int revision;
  final bool isRestoring;
  final ProductiveCategory? category;
  final ContextLabels labels;
  final List<ProductiveOperation> allowedOperations;
  final DateTime? resolvedFor;

  AgriculturalContext copyWith({
    String? parcelId,
    bool clearParcel = false,
    String? sectorId,
    bool clearSector = false,
    String? seasonId,
    bool clearSeason = false,
    String? assignmentId,
    bool clearAssignment = false,
    int? revision,
    bool? isRestoring,
    ProductiveCategory? category,
    ContextLabels? labels,
    List<ProductiveOperation>? allowedOperations,
    DateTime? resolvedFor,
  }) => AgriculturalContext(
    ownerId: ownerId,
    parcelId: clearParcel ? null : parcelId ?? this.parcelId,
    sectorId: clearSector ? null : sectorId ?? this.sectorId,
    seasonId: clearSeason ? null : seasonId ?? this.seasonId,
    assignmentId: clearAssignment ? null : assignmentId ?? this.assignmentId,
    revision: revision ?? this.revision,
    isRestoring: isRestoring ?? this.isRestoring,
    category: category ?? this.category,
    labels: labels ?? this.labels,
    allowedOperations: allowedOperations ?? this.allowedOperations,
    resolvedFor: resolvedFor ?? this.resolvedFor,
  );
}

final class BoundAgriculturalContext {
  const BoundAgriculturalContext({
    required this.ownerId,
    required this.parcelId,
    required this.sectorId,
    required this.seasonId,
    required this.assignmentId,
    required this.revision,
    this.category = ProductiveCategory.legacyUnknown,
    this.labels = const ContextLabels(),
    this.allowedOperations = const <ProductiveOperation>[],
    this.resolvedFor,
  });

  factory BoundAgriculturalContext.from(
    AgriculturalContext context, {
    String? parcelId,
    String? sectorId,
    String? seasonId,
    String? assignmentId,
    ProductiveCategory? category,
    ContextLabels? labels,
    List<ProductiveOperation>? allowedOperations,
    DateTime? resolvedFor,
  }) => BoundAgriculturalContext(
    ownerId: context.ownerId,
    parcelId: parcelId ?? context.parcelId,
    sectorId: sectorId ?? context.sectorId,
    seasonId: seasonId ?? context.seasonId,
    assignmentId: assignmentId ?? context.assignmentId,
    revision: context.revision,
    category: category ?? context.category ?? ProductiveCategory.legacyUnknown,
    labels: labels ?? context.labels,
    allowedOperations: allowedOperations ?? context.allowedOperations,
    resolvedFor: resolvedFor ?? context.resolvedFor,
  );

  final String? ownerId;
  final String? parcelId;
  final String? sectorId;
  final String? seasonId;
  final String? assignmentId;
  final int revision;
  final ProductiveCategory category;
  final ContextLabels labels;
  final List<ProductiveOperation> allowedOperations;
  final DateTime? resolvedFor;

  bool differsFrom(AgriculturalContext current) =>
      ownerId != current.ownerId ||
      parcelId != current.parcelId ||
      sectorId != current.sectorId ||
      seasonId != current.seasonId ||
      assignmentId != current.assignmentId;
}
