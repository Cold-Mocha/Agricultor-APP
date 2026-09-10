import 'package:agrocampo_backend/src/modules/agricultural_context/domain/entities/productive_domain.dart';

final class ContextOption {
  const ContextOption({
    required this.id,
    required this.name,
    this.category,
  });
  final String id;
  final String name;
  final ProductiveCategory? category;
}

final class BoundContextSummary {
  const BoundContextSummary({
    this.parcelName,
    this.sectorName,
    this.category,
    this.allowedOperations = const <ProductiveOperation>[],
  });
  final String? parcelName;
  final String? sectorName;
  final ProductiveCategory? category;
  final List<ProductiveOperation> allowedOperations;
}
